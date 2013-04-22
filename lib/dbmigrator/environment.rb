require 'active_record/migration'

module DbMigrator
  module Environment
    module_function :production?, :local?

    def production?
      "production" == ENV["DMB_ENV"]
    end

    def local?
      "local" == ENV["DBM_ENV"]
    end
  end
end

ActiveRecord::Migration.class_eval do
  include DbMigrator::Environment
end
