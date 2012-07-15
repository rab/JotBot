require 'singleton'
require 'fileutils'
require 'configuration'
require 'sequel'

class DatabaseManager
  include Singleton

  def initialize
    @database = nil  
  end


  def setup_database
    database_location = Configuration.database_location
    unless File.directory?(database_location)
      Configuration.logger.info "Creating new database directory at: #{database_location}"
      Dir.mkdir(database_location)
    end
    db_dir = "#{database_location}/database"
    @database = Sequel.connect( "jdbc:h2:#{File.expand_path(db_dir)}" )
    @database.loggers << Logger.new(File.new(File.expand_path(database_location + '/database.log'), 'w'))

    begin
      require 'migrate_database'
    rescue Exception  =>  e
      LOGGER.error "Error when processing 'migrate_database': #{e}"
      raise
    end
    require_model_classes
  end

  def db
    unless @database
      setup_database
    end
    @database
  end

  def require_model_classes
    %w{ report_filter 
        report
        timelog_detail 
        timelog
        category
      }.each{|m| require m}
  end
end
