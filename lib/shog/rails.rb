require 'rails'

module Shog
  module Rails

    # Automatically integrate Shog with the rails logger.
    class Railtie < ::Rails::Railtie
      config.before_initialize do
        next if ::Rails.logger.formatter.class == Shog::Formatter
        ::Rails.logger.formatter = Shog::Formatter.new.configure do
          with :defaults
          with :requests
        end
      end
    end

  end
end
