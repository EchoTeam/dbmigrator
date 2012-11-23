require "active_record/connection_adapters/postgresql_adapter"

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
  def supports_ddl_transactions?
    false # switch off auto transaction to avoid problems with index concerently
  end
end
