module Shog
  module Formatters
    # Default formatting options
    module Defaults
      module_function

      def configure( formatter )
        formatter.configure do
          severity_tag( :debug ) { |msg| msg.black.bold }
          severity_tag( :warn  ) { |msg| msg.yellow }
          severity_tag( :error ) { |msg| msg.red }
          severity_tag( :fatal ) { |msg| msg.white_on_red }

          severity( :error ){ |msg| msg.red }
          severity( :fatal ){ |msg| msg.red }
        end
      end
    end
  end
end