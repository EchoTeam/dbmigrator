require 'rubygems'
require 'bundler/setup'

begin
  require 'jeweler'
rescue LoadError => e
  $stderr.puts "Jeweler, or one of its dependencies, is not available:"
  $stderr.puts "#{e.class}: #{e.message}"
  $stderr.puts "Install it with: sudo gem install jeweler"
else
  Jeweler::Tasks.new do |gem|
    gem.name = 'dbmigrator'
    gem.summary = "Standalone migrator for non Rails projects"
    gem.email = "vasenin@aboutecho.com"
    gem.homepage = "http://github.com/EchoTeam/dbmigrator"
    gem.authors = ["Andrey Vasenin"]
  end
  Jeweler::GemcutterTasks.new
end
