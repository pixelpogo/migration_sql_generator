module MigrationSqlGenerator
  class Migration
    attr_accessor :full_name

    def initialize(migration_file)
      self.full_name = File.basename(migration_file, ".rb")
      require "db/migrate/#{full_name}"
    end

    def number
      /^(\d+)_(.*)$/.match(full_name)[1]
    end

    def name
      /^(\d+)_(.*)$/.match(full_name)[2]
    end

    def to_s
      full_name
    end

    def migration_class
      name.camelize.constantize
    end

    def up
      migration_class.up
      connection.execute("INSERT INTO schema_migrations (version) VALUES (#{number})")
    end

    def down
      migration_class.down
      connection.execute("DELETE FROM schema_migrations WHERE version = #{number}")
    end

    def connection
      ActiveRecord::Base.connection
    end
  end
end