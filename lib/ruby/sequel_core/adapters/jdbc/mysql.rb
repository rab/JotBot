require 'sequel_core/adapters/shared/mysql'

module Sequel
  module JDBC
    # Database and Dataset instance methods for MySQL specific
    # support via JDBC.
    module MySQL
      # Database instance methods for MySQL databases accessed via JDBC.
      module DatabaseMethods
        include Sequel::MySQL::DatabaseMethods

        # Return instance of Sequel::JDBC::MySQL::Dataset with the given opts.
        def dataset(opts=nil)
          Sequel::JDBC::MySQL::Dataset.new(self, opts)
        end

        # Typecast the value to the given column_type. Can be overridden in
        # adapters to support database specific column types.
        # This method should raise Sequel::Error::InvalidValue if assigned value
        # is invalid.
        def typecast_value(column_type, value)
          return nil if value.nil?
          case column_type
          when :integer
            begin
              Integer(value)
            rescue ArgumentError => e
              raise Sequel::Error::InvalidValue, e.message.inspect
            end
          when :string
            value.to_s
          when :float
            begin
              Float(value)
            rescue ArgumentError => e
              raise Sequel::Error::InvalidValue, e.message.inspect
            end
          when :decimal
            case value
            when BigDecimal
              value
            when String, Float
              value.to_d
            when Integer
              value.to_s.to_d
            else
              raise Sequel::Error::InvalidValue, "invalid value for BigDecimal: #{value.inspect}"
            end
          when :boolean
            case value
            when false, 0, "0", /\Af(alse)?\z/i
              false
            else
              value.blank? ? nil : true
            end
          when :date
            case value
            when Date
              value
            when DateTime, Time
              Date.new(value.year, value.month, value.day)
            when String
              value.to_date
            else
              raise Sequel::Error::InvalidValue, "invalid value for Date: #{value.inspect}"
            end
          when :time
            case value
            when Time
              value
            when String
              value.to_time
            else
              raise Sequel::Error::InvalidValue, "invalid value for Time: #{value.inspect}"
            end
          when :datetime
            raise(Sequel::Error::InvalidValue, "invalid value for Datetime: #{value.inspect}") unless value.is_one_of?(DateTime, Date, Time, String)
            if Sequel.datetime_class === value
              # Already the correct class, no need to convert
              value
            elsif value.is_a?(DateTime)
              value.strftime("%Y-%m-%d %H:%M:%S") 
            elsif value.is_a?(String)
              value  # Risky!  FIXME
            else
              # First convert it to standard ISO 8601 time, then
              # parse that string using the time class.
              (Time === value ? value.iso8601 : value.to_s).to_sequel_time
            end
          when :blob
            value.to_blob
          else
            value
          end
        end


        private

        # The database name for the given database.  Need to parse it out
        # of the connection string, since the JDBC does no parsing on the
        # given connection string by default.
        def database_name
          u = URI.parse(uri.sub(/\Ajdbc:/, ''))
          (m = /\/(.*)/.match(u.path)) && m[1]
        end

        # Get the last inserted id using LAST_INSERT_ID().
        def last_insert_id(conn, opts={})
          stmt = conn.createStatement
          begin
            rs = stmt.executeQuery('SELECT LAST_INSERT_ID()')
            rs.next
            rs.getInt(1)
          ensure
            stmt.close
          end
        end
      end

      # Dataset class for MySQL datasets accessed via JDBC.
      class Dataset < JDBC::Dataset
        include Sequel::MySQL::DatasetMethods

        # Use execute_insert to execute the insert_sql.
        def insert(*values)
          execute_insert(insert_sql(*values))
        end

        # Use execute_insert to execute the replace_sql.
        def replace(*args)
          execute_insert(replace_sql(*args))
        end

        private

        # Call execute_insert on the database.
        def execute_insert(sql, opts={})
          @db.execute_insert(sql, {:server=>@opts[:server] || :default}.merge(opts))
        end
      end
    end
  end
end
