require 'active_support/tagged_logging'
require 'colored'

module Shog

  # A rails logger formatter that spices up the log message adding color to
  # and context to log messages.
  #
  # Shog automatically overrides the default formatter in your rails app. Use
  # {Shog.configure} to configure the default logger.
  class Formatter < ::ActiveSupport::Logger::SimpleFormatter

    include ActiveSupport::TaggedLogging::Formatter

    def initialize
      reset_config!
    end

    # Called by the logger to prepare a message for output.
    # @return [String]
    def call( severity, time, progname, msg )
      return if msg.blank? || _silence?( msg )

      msg = [
        _tagged( time, :timestamp ),
        _tagged( progname, :progname ),
        formatted_severity_tag( severity ),
        formatted_message( severity, msg )
      ].compact.join(" ")

      super severity, time, progname, msg
    end

    # Formats the message according to the configured {#match} blocks.
    #
    # @param [String] msg to format.
    # @return [String] the formatted message.
    def formatted_message( severity, msg )
      msg = String === msg ? msg : msg.inspect

      if args = _matched( msg )
        args.first.call msg, args.last
      elsif proc = configuration[:severities][severity]
        proc.call msg
      else
        msg
      end
    end

    # Formats the severity indicator prefixed before each line when writing to
    # the log.
    #
    # @param [String] the severity of the message (ex DEBUG, WARN, etc.)
    # @return [String] formatted version of the severity
    def formatted_severity_tag( severity )
      length = configuration[:severity_tags][:_length] ||= begin
        configuration[:severity_tags].reduce(0){ |l,(k,_)| [k.length,l].max }
      end

      return if length == 0

      padded_severity = severity.ljust length

      formatted = if proc = configuration[:severity_tags][severity]
                    proc.call padded_severity
                  else
                    padded_severity
                  end
      _tagged formatted, :severity_tags
    end

    # Formats a time value expressed in ms, adding color to highlight times
    # outside the expected range.
    #
    # If `time` is more thatn `expected` it's highligted yellow. If it's more
    # than double it's highlighted red.
    #
    # @param [String] time in ms.
    # @param [Float] expected maximum amount of time it should have taken.
    # @return [String] the formatted time.
    def format_time( time, expected = 30 )
      timef = time.uncolorize.to_f
      case
      when timef > expected * 2 then time.to_s.uncolorize.red
      when timef > expected     then time.to_s.uncolorize.yellow
      else time
      end
    end


    # ==========================================================================
    # @!group Configuration

    # Set up log message formatting for this formatter.
    #
    # @yield and executes the block where self is this formatter.
    # @return [Formatter] self.
    #
    # @example
    #   Formatter.new.configure do
    #     with :defaults
    #     timestamp
    #     severity(:error){ |msg| msg.red }
    #     severity(:fatal){ |msg| "\b#{msg}".red }
    #   end
    def configure( &block )
      instance_eval( &block )
      self
    end

    # Format the severity indicator tagged before each line. To format the
    # actual message itself use {#severity}.
    #
    # @overload severity_tag( level, proc )
    #   @param [String,Symbol] level to format.
    #   @param [#call(level)] proc that receives the log level and returns the
    #     reformatted level.
    #
    # @overload severity_tag( level )
    #   @param [String,Symbol] level to format.
    #   @yieldparam level [String] the log level to reformat.
    #   @yieldreturn [String] the reformatted level.
    #
    # @return [Formatter] self.
    #
    # @example
    #   configure do
    #     severity_tag(:warn){|level| level.yellow }
    #     severity_tag(:error){|level| level.red }
    #   end
    def severity_tag( level, proc = nil, &block )
      proc ||= block
      configuration[:severity_tags][ level.to_s.upcase ] = proc
      self
    end

    # Provide default formatting for messages of the given severity when
    # a {#match} is not found.
    #
    # @overload severity( level, proc )
    #   @param [String,Symbol] level to format.
    #   @param [#call(msg)] proc that receives the message and returns the
    #     reformatted message.
    # @overload severity( level )
    #   @param [String,Symbol] level to format.
    #   @yieldparam msg [String] the message to reformat.
    #   @yieldreturn [String] the reformatted message.
    #
    # @return [Formatter] self.
    #
    # @example
    #   configure do
    #     severity(:fatal){ |msg| msg.white_on_red }
    #   end
    def severity( level, proc = nil, &block )
      proc ||= block
      configuration[:severities][ level.to_s.upcase ] = proc
      self
    end

    # Resets any previously configured formatting settings.
    # @return [Formatter] self.
    def reset_config!
      @configuration = {
        severity_tags: {},
        severities: {},
        matchers: {},
        silencers: []
      }
      self
    end

    # Re-format any log messages that match the given `pattern`.
    #
    # @overload match( pattern, proc)
    #   @param [Regexp] pattern to match against the log message.
    #   @param [#call(message,last_match)] proc a callable object that receives
    #     the message and the last match and re-formats the message.
    #
    # @overload match( pattern )
    #   @param [Regexp] pattern to match against the log message.
    #   @yieldparam message [String] the matched log message.
    #   @yieldparam last_match [MatchData] the regex matches.
    #   @yieldreturn [String] the re-formatted message.
    #
    # @example
    #   configure do
    #     match /GET (?<address>.*)/ do |message,last_match|
    #       "GETTING -> #{last_match['address'].green}"
    #     end
    #   end
    # @return [Formatter] self.
    def match( pattern, proc = nil, &block )
      proc ||= block
      configuration[:matchers][pattern] = proc
      self
    end

    # When a log message matches the given `pattern` don't log it.
    #
    # @param [Regexp] pattern to match.
    #
    # @return [Formatter] self.
    #
    # @example
    #   configure do
    #     silence /assets\/bootstrap/
    #   end
    def silence( pattern )
      configuration[:silencers] << pattern
      self
    end

    # Use configuration defined in the given module.
    #
    # @param [Symobl,#configure] mod the name of the shog module to use or an
    #   object that responds to `#configure`.
    #
    # @return [Formatter] self.
    #
    # When `mod` is a symobl, it loads one of the modules from
    # {Shog::Formatters} and uses any configuration options sepcified in that
    # module.
    #
    # Otherwise `mod` must respond to `#configure` taking a single argument -
    # this formatter.
    #
    # @example Built-in Formatters
    #   configure do
    #     with :defaults
    #     with :requests
    #   end
    #
    # @example Custom Shared Formatters
    #   module MyFormatters
    #     def self.configure( formatter )
    #       formatter.configure do
    #         timestamp
    #       end
    #     end
    #   end
    #
    #   configure do
    #     with MyFormatters
    #   end
    def with( mod )
      unless mod.is_a? Module
        mod = "Shog::Formatters::#{mod.to_s.camelize}".constantize
      end

      mod.configure self
      self
    end

    # Include timestamp in logged messages.
    # @param [Boolean] enable or disable timestamping of log messages.
    # @return [Formatter] self.
    def timestamp( enable = true )
      configuration[:timestamp] = enable
      self
    end

    # Include the progname in logged messages.
    # @param [Boolean] enable or disable tagging with the prog name of log messages.
    # @return [Formatter] self.
    def progname( enable = true )
      configuration[:progname] = enable
      self
    end

    # @!endgroup

    private

      attr_accessor :configuration

      def _matched( msg )
        if matched =  configuration[:matchers].find do |pattern,_|
                        pattern === msg
                      end
          [matched.last, Regexp.last_match]
        end
      end

      def _tagged( val, config_key )
        return unless configuration[config_key]
        "[#{val}]"
      end

      def _silence?( msg )
        configuration[:silencers].any?{|p| p === msg }
      end
  end
end
