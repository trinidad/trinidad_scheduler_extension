begin
  require 'bundler/gem_helper'
rescue LoadError => e
  require('rubygems') && retry
  raise e
else
  Bundler::GemHelper.install_tasks
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = ['--color', "--format documentation"]
  spec.pattern = 'spec/**/*_spec.rb'
end
task :test => :spec

task :default => :spec
