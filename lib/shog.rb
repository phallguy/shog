require 'shog/version'
require 'shog/formatter'
require 'shog/formatters'
require 'shog/rails'
require 'shog/extensions'

module Shog

  # Set up formatting options for the default rails logger.
  # @see Shog::Formatter#configure
  def self.configure(&block)
    formatter = ::Rails.logger.formatter
    unless formatter.is_a? Shog::Formatter
      formatter = ::Rails.logger.formatter = Shog::Formatter.new
    end
    formatter.configure &block
  end
end
