module Shog
  module Formatters
    # Provide common log formatting options for rails request logs such as
    # controller names views, and render times.
    module Requests
      module_function

      # @see Shog::Formatter#configure
      # @see Shog::Formatter#with
      def configure( formatter )
        formatter.configure do

          # Highlight HTTP request methods
          match /Started\s+(?<method>PUT|PATCH|GET|POST|DELETE)\s+(?<path>"[^"]*")[^\d\.]+(?<ip>[\d\.]+)(?<time>.*)/ do |msg,match|
            # http://refiddle.com/ge6
            "#{match["method"].ljust 6} ".green.bold + " #{match["path"]} ".white.bold + " for " + "#{match["ip"]}".yellow + " #{match["time"]}".black
          end

          # Dim detailed info about rendering views
          match /\s*Rendered\s+(?<view>[^\s]+)\s(within\s(?<layout>[^\s]+)\s)?\((?<time>.*)\)/ do |msg,match|
            # http://refiddle.com/18qr
            parts = ["  Rendered #{ match["view"].bold }".black]
            parts << "within ".black + match["layout"].black.bold if match['layout']
            parts << format_time( match['time'].black, 50 )
            parts.join " "
          end

          # Highlight the final rendered response
          match /\s*Completed\s(?<code>\d+)\s(?<friendly>.*)\sin\s(?<time>\d+[^\s]*)\s(?<details>.*)/ do |msg,match|
            # http://refiddle.com/18qq
            parts = [ "Completed" ]
            status = "#{match['code']} #{match['friendly']}"
            parts <<  case match['code'].to_i
                      when 200..399 then status.green
                      when 400..499 then status.yellow
                      else               status.red
                      end
            parts << 'in'
            parts << format_time( match['time'], 250 )
            parts << match['details'].black

            parts.join(" ")
          end

          # Highlight the controller and action responding to the request
          match /Processing by (?<controller>[^\s]*) as (?<format>.*)/ do |msg,match|
            # http://refiddle.com/18qs
            "===".magenta + " Processing by #{match['controller'].magenta} as #{match['format'].yellow}"
          end

        end
      end

    end
  end
end
