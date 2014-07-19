require 'simplecov'
if ENV['COVERAGE']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
else
  SimpleCov.start
end

require 'shog'

root_path = File.expand_path( "../..", __FILE__ )

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[ File.join( root_path, "spec/support/**/*.rb" ) ].each { |f| require f }

RSpec.configure do |config|

  config.order = "random"

  config.filter_run focus: true
  config.filter_run_excluding :broken => true
  config.run_all_when_everything_filtered = true

  config.before(:each)  { GC.disable }
  config.after(:each)   { GC.enable }

end