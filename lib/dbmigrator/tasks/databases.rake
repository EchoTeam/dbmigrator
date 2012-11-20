require 'rails/generators'
require 'rails/generators/active_record/migration/migration_generator'

module ActiveRecord
  module Generators
    class MigrationGenerator
      class_option :location, :type => :string, :default => "db/migrate"

      def create_migration_file
        set_local_assigns!
        validate_file_name!
        migration_template "migration.rb", File.join(options[:location], "#{file_name}.rb")
      end

      protected
        def validate_file_name!
          unless file_name =~ /^[_a-z0-9]+$/
            raise IllegalMigrationNameError.new(file_name)
          end
        end
    end
  end
end

Rake::TaskManager.class_eval do
  def alias_task(fq_name)
    new_name = "#{fq_name}:original"
    @tasks[new_name] = @tasks.delete(fq_name)
  end
end

def alias_task(fq_name)
  Rake.application.alias_task(fq_name)
end

def override_task(*args, &block)
  name, params, deps = Rake.application.resolve_args(args.dup)
  fq_name = Rake.application.instance_variable_get(:@scope).dup.push(name).join(':')
  alias_task(fq_name)
  Rake::Task.define_task(*args, &block)
end

def options
  Hash[ENV.map{|key,value| [key.to_s.downcase.parameterize.underscore.to_sym,value]}]
end

load "active_record/railties/databases.rake"

namespace :db do
  namespace :migration do
    desc 'Create new migration'
    task :new => ["db:set_migration_paths"] do |t, args|
      if ([:name, :group].all?{|key| options[key].present?})
        ActiveRecord::Migrator.migrations_paths.each do |path|
          Rails::Generators.invoke "active_record:migration", [options[:name], "--location=#{path}"],
            :destination_root => Rails.root
        end
      else
        puts "Error: you must provide name and group to generate migration."
        puts "For example: rake #{t.name} NAME=add_field_to_form GROUP=items"
      end
    end
  end

  task :establish_connection do
    if ([:user, :database, :host].any?{|key| options[key].blank?})
      puts "You should specify USER HOST and DATABASE variables to establist connection to database"
      puts "Example: rake db:migrate USER=user DATABASE=echo_development HOST=localhost GROUP=items"
      abort
    end
    configuration = {
        'adapter' => 'postgresql',
        'host' => options[:host],
        'username' => options[:user],
        'password' => options[:password],
        'database' => options[:database],
        'encoding' => 'utf8' }
    ActiveRecord::Base.configurations = {ENV["RAILS_ENV"] => configuration}
    ActiveRecord::Base.establish_connection configuration
    if (ActiveRecord::Base.connected?)
      ActiveRecord::Base.connection.instance_eval do
        def supports_ddl_transactions?
          false # switch to manual transaction support
        end
      end
    end
  end

  task :set_migration_paths do
    if (options[:group].blank?)
      puts "You should specify GROUP variable to set correct migration folder"
      puts "Example: rake db:migrate USER=user DATABASE=echo_development HOST=localhost GROUP=items"
      abort
    end

    ActiveRecord::Base.schema_format = :sql

    root_folder = File.join(Rails.root, "db", options[:group])
    FileUtils.mkdir_p root_folder

    ActiveRecord::Migrator.migrations_paths = [File.join(root_folder, "migrate")]
    Rails.application.paths['db/seeds'] = File.join(root_folder, "seed.rb")
    ENV['DB_STRUCTURE'] = File.join(root_folder, "structure.sql")
  end

  override_task :load_config => [:establish_connection, :set_migration_paths] do
  end
end


