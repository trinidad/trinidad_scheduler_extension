require 'rubygems'
require 'rake'
require 'lib/trinidad_scheduler_extension/version'

namespace :scheduler do
  begin
    require 'jeweler'
    Jeweler::Tasks.new do |gem|
      gem.name = "trinidad_scheduler_extension"
      gem.summary = "Extension to support scheduled jobs in Trinidad: Extension"
      gem.description = "Extension to support scheduled jobs in Trinidad"
      gem.email = "brandon+trinidad_scheduler@myjibe.com"
      gem.homepage = "https://github.com/trinidad/trinidad_scheduler_extension"
      gem.authors = ["Brandon Dewitt"]
      gem.add_dependency "trinidad_jars"

      gem.files = FileList['lib/trinidad_scheduler_extension.rb', 
                           'lib/trinidad_scheduler_extension/version.rb',
                           'lib/trinidad_scheduler_extension/scheduler_extension.rb',
                           'lib/trinidad_scheduler_extension/trinidad_scheduler.rb',
                           'lib/trinidad_scheduler_extension/extensions/object.rb',
                           'lib/trinidad_scheduler_extension/scheduled_job.rb',
                           'lib/trinidad_scheduler_extension/app_job.rb',
                           'lib/trinidad_scheduler_extension/scheduler_listener.rb',
                           'lib/trinidad_scheduler_extension/job_factory.rb',
                           'lib/trinidad_scheduler_extension/job_detail.rb',
                           'lib/trinidad_scheduler_extension/config/log4j.properties',
                           'lib/trinidad_scheduler_extension/jars/log4j-1.2.16.jar',
                           'lib/trinidad_scheduler_extension/jars/quartz-1.8.4.jar', 
                           'lib/trinidad_scheduler_extension/jars/slf4j-api-1.6.1.jar',
                           'lib/trinidad_scheduler_extension/jars/slf4j-log4j12-1.6.1.jar',
                           'README.rdoc',
                           'LICENSE']
      gem.has_rdoc = true
      gem.version = TrinidadScheduler::VERSION
    end
    Jeweler::GemcutterTasks.new
  rescue LoadError
    puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
  end
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |spec|
  spec.rspec_opts = ["-c", "-f progress", "-r ./rspec/spec_helper.rb"]
  spec.pattern = 'rspec/**/*_spec.rb'
end

task :default => :spec

