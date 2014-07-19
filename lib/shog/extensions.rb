module Shog
  module Extensions
    module Colored
      extend self

      # Removes any ASCII color encoding
      def uncolorize
        # http://refiddle.com/18rj
        gsub /\e\[\d+(;\d+)*m/, ''
      end


    end
  end
end

String.send :include, Shog::Extensions::Colored