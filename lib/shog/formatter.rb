require 'active_support/tagged_logging'
require 'colored'

module Shog
  class Formatter < ::ActiveSupport::Logger::SimpleFormatter

    include ActiveSupport::TaggedLogging::Formatter

    def call( severity, time, progname, msg )
      return if msg.blank?
      tagged formatted_severity_tag( severity ) do
        msg = formatted_message( severity, msg )
        msg = timestamped_message( time, msg )
        msg = prognamed_message( progname, msg )

        super severity, time, progname, msg
      end
    end

    def initialize
      reset_config!
    end

    # Formats the message according to the configured settings.
    # @param [String] msg to format.
    def formatted_message( severity, msg )
      msg = String === msg ? msg : msg.inspect

      if args = matched( msg )
        args.first.call msg, args.last
      elsif proc = configuration[:severities][severity]
        proc.call msg
      else
        msg
      end
    end

    # Formats the severity indicator prefixed before each line when writing to
    # the log.
    # @param [String] the severity of the message (ex DEBUG, WARN, etc.)
    # @return [String] formatted version of the severity
    def formatted_severity_tag( severity )
      length = configuration[:severity_tags][:_length] ||= begin
        configuration[:severity_tags].reduce(0){ |l,(k,_)| [k.length,l].max }
      end

      padded_severity = severity.ljust length

      if proc = configuration[:severity_tags][severity]
        proc.call padded_severity
      else
        padded_severity
      end
    end

    # Formats a ms time value.
    def format_time( time, expected = 30 )
      timef = time.to_f
      case
      when timef > expected * 2 then time.to_s.red
      when timef > expected     then time.to_s.yellow
      else time
      end
    end


    # ==========================================================================
    # @!group Configuration

    # Configure messages formatting for this formatter.
    def configure( &block )
      instance_eval( &block )
      self
    end

    # Format the severity tagged before each line.
    def severity_tag( level, &block )
      configuration[:severity_tags][ level.to_s.upcase ] = block
    end

    # Provide customized formatting for messages of the given severity when they
    # a custom matcher cannot be found.
    # @param [String,Symbol] level to format.
    def severity( level, &block )
      configuration[:severities][ level.to_s.upcase ] = block
    end

    # Resets any previously configured formatting settings.
    def reset_config!
      @configuration ||= {
        severity_tags: {},
        severities: {},
        matchers: {}
      }
      self
    end

    # When a log message matches the given pattern, provide a custom format
    # for it.
    def match( pattern, &block )
      configuration[:matchers][pattern] = block
    end

    # Adds the named matchers to the log
    def formatter( mod )
      unless mod.is_a? Module
        mod = "Shog::Formatters::#{mod.to_s.camelize}".constantize
      end

      mod.configure self
    end

    # Include timestamp in logged messages.
    def timestamp( enabled = true )
      configuration[:timestamp] = enabled
    end

    # Include the progname in logged messages.
    def progname( enabled = true )
      configuration[:progname] = enabled
    end

    # @!endgroup

    private

      attr_accessor :configuration

      def matched( msg )
        if matched =  configuration[:matchers].find do |pattern,_|
                        pattern === msg
                      end
          [matched.last, Regexp.last_match]
        end
      end

      def timestamped_message( time, msg )
        return msg unless configuration[:timestamp]

        "[#{time}] #{msg}"
      end

      def prognamed_message( progname, msg )
        return msg unless configuration[:progname]

        "[#{progname}] #{msg}"
      end
  end
end
