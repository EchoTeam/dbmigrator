require 'active_record/migration'

module DbMigrator
  module Environment
    def env
      ENV["DBM_ENV"]
    end
   
    module_function :production?, :local?
  end
end

ActiveRecord::Migration.class_eval do
  include DbMigrator::Environment
end
