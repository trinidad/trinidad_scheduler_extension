require 'rubygems'
require 'rake'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |spec|
  spec.rspec_opts = ["-c", "-f progress", "-r ./rspec/spec_helper.rb"]
  spec.pattern = 'rspec/**/*_spec.rb'
end

task :default => :spec
