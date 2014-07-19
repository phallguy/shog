module Shog
  module Formatters
    # Format log messages from the request processing such as controller endpoints and views.
    module Requests
      module_function

      def configure( formatter )
        formatter.configure do
          match /Started\s+(?<method>PUT|PATCH|GET|POST|DELETE)\s+(?<path>"[^"]*")[^\d\.]+(?<ip>[\d\.]+)(?<time>.*)/ do |msg,match|
            # http://refiddle.com/ge6
            "#{match["method"].ljust 6} ".green.bold + " #{match["path"]} ".white.bold + " for " + "#{match["ip"]}".yellow + " #{match["time"]}".black.bold
          end

          match /\s*Rendered\s+(?<view>[^\s]+)\swithin\s(?<layout>[^\s]+)\s\((?<time>.*)\)/ do |msg,match|
            # http://refiddle.com/18qr
            "  Rendered " + match["view"].white.bold + " within " + match["layout"].white + " " + format_time( match['time'] )
          end

          match /\s*Completed\s(?<code>\d+)\s(?<friendly>.*)\sin\s(?<time>\d+[^\s]*)\s(?<details>.*)/ do |msg,match|
            # http://refiddle.com/18qq
            parts = [ "Completed" ]
            parts <<  case match['code'].to_i
                      when 200..399 then match['code'].green
                      when 400..499 then match['code'].yellow
                      else               match['code'].red
                      end
            parts << match['friendly'].yellow
            parts << 'in'
            parts << format_time( match['time'], 250 )
            parts << match['details']

            parts.join(" ")
          end

          match /Processing by (?<controller>[^\s]*) as (?<format>.*)/ do |msg,match|
            # http://refiddle.com/18qs
            "Processing by #{match['controller'].magenta.bold} as #{match['format'].yellow}"
          end

        end
      end




    end
  end
end