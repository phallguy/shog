require 'shog/version'
require 'shog/formatter'
require 'shog/formatters'
require 'shog/rails'
require 'pry'

module Shog
  def self.configure(&block)
    ::Rails.logger.formatter.configure &block
  end
end