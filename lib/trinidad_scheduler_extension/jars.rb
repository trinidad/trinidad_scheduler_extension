require 'java'

['log4j-1.2.16','slf4j-api-1.6.1','slf4j-log4j12-1.6.1','quartz-1.8.4'].each do |jar|
  load File.expand_path("../../trinidad-libs/#{jar}.jar", File.dirname(__FILE__))
end