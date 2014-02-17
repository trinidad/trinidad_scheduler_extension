require 'java'

['log4j-1.2.17','slf4j-api-1.6.6','slf4j-log4j12-1.6.6','quartz-1.8.6'].each do |jar|
  load File.expand_path("../../trinidad-libs/#{jar}.jar", File.dirname(__FILE__))
end