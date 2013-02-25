require 'active_record/migration'

ActiveRecord::Migration.class_eval do
  def local?
    "local" == ENV["DBM_ENV"]
  end

  def production?
    "production" == ENV["DMB_ENV"]
  end
end
