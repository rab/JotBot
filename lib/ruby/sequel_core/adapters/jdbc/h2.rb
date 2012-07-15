module Sequel
  module JDBC
    # We override the default behavior to ensure that column names are returned as lower-case strings
    class Dataset 

      # alias_method :original_execute_dui, :execute_dui

      def quoted_identifier(name)
        name.to_s
      end


      def fetch_rows(sql, &block)
        execute(sql) do |result|
          # get column names
          meta = result.getMetaData
          column_count = meta.getColumnCount
          @columns = []
          # downcase added by JGB
          column_count.times {|i| @columns << meta.getColumnName(i+1).downcase.to_sym}

          # get rows
          while result.next
            row = {}
            @columns.each_with_index {|v, i| row[v] = result.getObject(i+1)}
            yield row
          end
        end
        self
      end

      # For whatever reasons, the default insert was not passing along the :type value, so later code 
      # did not know to go grab the last_insert_id
      def insert(*values)
        execute_dui(insert_sql(*values), {:type => :insert})
      end


    end
  end

  class Database
    def serial_primary_key_options
      {:primary_key => true, :type => :identity, :auto_increment => false}
    end

    def last_insert_id(conn, opts={})
      stmt = conn.createStatement
      begin
        rs = stmt.executeQuery('SELECT IDENTITY(); ')
        rs.next
        rs.getInt(1)
      ensure
        stmt.close
      end
    end
  end

end

module Sequel
  module JDBC
    module H2
      module DatabaseMethods
        def last_insert_id(conn, opts={})
          stmt = conn.createStatement
          begin
            rs = stmt.executeQuery('SELECT IDENTITY(); ')
            rs.next
            rs.getInt(1)
          ensure
            stmt.close
          end
        end
      end
    end
  end
end



