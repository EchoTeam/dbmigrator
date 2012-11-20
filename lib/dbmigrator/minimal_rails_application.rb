module DbMigrator
  class MinimalRailsApplication < Rails::Application
    config.generators.options[:rails] = {:orm => :active_record}

    config.generators.options[:active_record] = {
      :migration => true,
      :timestamps => true
    }

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
    end
  end
end
