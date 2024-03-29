namespace :db do
  [ :migrate, :rollback ].each do |n|
    namespace n do |migration_task|

      original_task = migration_task.instance_variable_get("@scope").to_a.reverse.join ":"

      [:with_sql, :to_sql ].each do |t|

        desc "Run migration, and generated SQL" if t == :with_sql
        desc "Generate migration SQL" if t == :to_sql
        task t => :environment do |sql_task|

          case original_task
          when "db:migrate"
            filename = 'upgrade.sql'
          when "db:rollback"
            filename = 'rollback.sql'
          else
            raise "unkown migration type #{original_task}"
          end

          ActiveRecord::Base.connection.class.class_eval do
            # alias the adapter's execute for later use
            alias :old_execute :execute

            SQL_FILENAME = filename
            RUN_SQL = sql_task.name.ends_with?("with_sql")

            # define our own execute
            def execute(sql, name = nil)
              # check for some DDL and DML statements
              if /^(create|alter|drop|insert|delete|update)/i.match sql
                File.open(SQL_FILENAME, 'a') { |f| f.puts "#{sql};\n" }
                old_execute sql, name if RUN_SQL
              else
                # pass everything else to the aliased execute
                old_execute sql, name
              end
            end

          end

          # create or delete content of migration.sql
          File.open(SQL_FILENAME, 'w') { |f| f.puts "-- Script created @ #{Time.now}" }

          # invoke the normal migration procedure now
          Rake::Task[original_task].invoke

          puts "Ran #{original_task} and wrote sql to #{filename}"
        end
      end
    end
  end

end
