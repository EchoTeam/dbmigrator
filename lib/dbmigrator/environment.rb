require 'active_record/migration'

module DbMigrator
  module Environment
    def production?
      "production" == ENV["DBM_ENV"]
    end

    def local?
      !production?
    end

    module_function :production?, :local?
  end
end

ActiveRecord::Migration.class_eval do
  include DbMigrator::Environment
end
