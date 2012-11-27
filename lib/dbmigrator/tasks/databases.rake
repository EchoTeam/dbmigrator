$:.unshift File.dirname(__FILE__)
require "task_manager"
require "migration_generator"
require "postgres"

load "active_record/railties/databases.rake"

db_namespace = namespace :db do
  desc "Use db:drop, db:create, db:migrate circle to reset database"
  task :reset_with_migrations do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
  end

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
    if (ENV["DATABASE_URL"].blank?)
      puts "You should specify DATABASE_URL variable to establist connection to database"
      puts "Example: rake db:migrate DATABASE_URL=postgres://avasenin@localhost/test_db GROUP=items"
      abort
    end
    ActiveRecord::Base.configurations = {Rails.env => database_url_config}
    ActiveRecord::Base.establish_connection database_url_config
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
    Rails.application.paths['db/setup'] = File.join(root_folder, "setup.rb")
    ENV['DB_STRUCTURE'] = File.join(root_folder, "structure.sql")
  end

  override_task :load_config => [:establish_connection, :set_migration_paths] do
  end

  override_task :create => [:load_config, :rails_env] do
    create_database(database_url_config)
    ActiveRecord::Base.establish_connection(database_url_config)
    set_psql_env(database_url_config)
    setup_file = Rails.application.paths["db/setup"].existent.first
    load(setup_file) if setup_file
  end

  namespace :structure do
    desc 'Dump the database structure to db/structure.sql. Specify another file with DB_STRUCTURE=db/my_structure.sql'
    task :dump => [:environment, :load_config] do
      config = current_config
      filename = ENV['DB_STRUCTURE'] || File.join(Rails.root, "db", "structure.sql")
      next unless config['adapter'] =~ /postgres/
      set_psql_env(config)
      `pg_dump -i -s -O -f #{Shellwords.escape(filename)} #{Shellwords.escape(config['database'])}`
      raise 'Error dumping database' if $?.exitstatus == 1
      if ActiveRecord::Base.connection.supports_migrations?
        File.open(filename, "a") { |f| f << ActiveRecord::Base.connection.dump_schema_information }
      end
      db_namespace['structure:dump'].reenable
    end
  end
end

def options
  Hash[ENV.map{|key,value| [key.to_s.downcase.parameterize.underscore.to_sym,value]}]
end

