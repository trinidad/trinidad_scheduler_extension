# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'trinidad_scheduler_extension/version'

Gem::Specification.new do |s|
  s.name = "trinidad_scheduler_extension"
  s.summary = "Trinidad extension for scheduling background jobs"
  s.description = "Trinidad Scheduler uses Quartz to schedule processes for execution. " + 
                  "It can be run as a server extension to Trinidad and/or a Web Application extension for Trinidad."
  s.email = "brandon+trinidad_scheduler@myjibe.com"
  s.homepage = "https://github.com/trinidad/trinidad_scheduler_extension"
  s.authors = ["Brandon Dewitt"]
  s.add_dependency "trinidad_jars"
  
  s.version = TrinidadScheduler::VERSION
  
  s.has_rdoc = true
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]
  
  s.require_paths = %w[lib]
  
  s.add_dependency('trinidad_jars', ">= 1.0.0")
  
  s.add_development_dependency('rspec', '~> 2.8')
  s.add_development_dependency('mocha', '>= 0.10.4')
  
  s.files = `git ls-files`.split("\n").sort.
    reject { |file| file =~ /rspec\// }
  
  #s.test_files = s.files.select { |path| path =~ /^rspec\/.*_spec\.rb/ }
  
end
