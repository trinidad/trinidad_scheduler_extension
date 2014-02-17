# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'trinidad_scheduler_extension/version'

Gem::Specification.new do |gem|
  gem.name = "trinidad_scheduler_extension"
  gem.version = Trinidad::Extensions::Scheduler::VERSION

  gem.summary = "Trinidad extension for scheduling background jobs"
  gem.description = "Trinidad Scheduler uses Quartz to schedule processes for execution. " <<
  "It can be run as a server extension to Trinidad and/or a Web Application extension for Trinidad."

  gem.email = "brandon+trinidad_scheduler@myjibe.com"
  gem.homepage = "https://github.com/trinidad/trinidad_scheduler_extension"
  gem.authors = ["Brandon Dewitt"]

  gem.has_rdoc = true
  gem.rdoc_options = ["--charset=UTF-8"]
  gem.extra_rdoc_files = %w[ README.md LICENSE ]

  gem.require_paths = ["lib"]

  gem.add_dependency 'trinidad', ">= 1.4.6"

  gem.add_development_dependency 'rspec', '~> 2.14.1'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'mocha', '>= 0.10.4'

  gem.files = `git ls-files`.split("\n").sort.reject { |file| file =~ /^spec\// }
  gem.test_files = gem.files.select { |path| path =~ /^spec\// }
end
