begin
  require 'bundler'
rescue LoadError => e
  require('rubygems') && retry
  raise e
end
Bundler.require(:default, :test)

require 'rspec'
require 'mocha'

lib = File.expand_path('../lib', File.dirname(__FILE__))
$: << lib if ! $:.include?(lib) && ! $:.include?('lib')
require 'trinidad_scheduler_extension'

RSpec.configure do |config|
  config.mock_framework = :mocha
end

MOCK_WEB_APP_DIR = File.join(File.dirname(__FILE__), 'web_app_mock')
