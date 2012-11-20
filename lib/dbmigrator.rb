lib_path = File.dirname(__FILE__)
$:.unshift lib_path unless $:.include?(lib_path)

require "rubygems"
require "rails"
require "active_record"

if !ENV["RAILS_ENV"]
    ENV["RAILS_ENV"] = ENV["RACK_ENV"] || Rails.env || "development"
end

require "dbmigrator/minimal_rails_application"

DbMigrator::MinimalRailsApplication.load_tasks
