require 'rails'

module Shog
  module Rails
    class Railtie < ::Rails::Railtie
      config.before_initialize do
        ::Rails.logger.formatter = Shog::Formatter.new.configure do
          formatter :defaults
          formatter :requests
        end
      end
    end
  end
end
