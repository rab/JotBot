require 'yaml'
require 'logger'

class ConfigurationException < Exception; end

class Configuration
  DEFAULT_DATA_LOCATION = File.expand_path("~/.jotbot")
  DEFAULT_POPUP_INTERVAL = 15
  DEFAULT_ALWAYS_ON_TOP = true
  DEFAULT_SHOW_HELP_WHEN_OPENING = false
  DEFAULT_LICENSE_KEY_FILE = "license.key"
  DEFAULT_REPORT_DIRECTORY = File.expand_path("~/.jotbot") # ??


  def self.java_version
    java.lang.System.get_property('java.version')
  end

  def self.load_from_existing_config_file
    begin
      if File.exist? 'configuration.yaml'
        @@logger.info "Loading from configuration.yaml in current working directory"
        @@config_data = YAML.load(File.new('configuration.yaml'))
        @@configuration_file_location = File.expand_path('configuration.yaml')
        true
      elsif File.exist? "#{DEFAULT_DATA_LOCATION}/configuration.yaml"
        @@logger.info "Loading from configuration.yaml at #{DEFAULT_DATA_LOCATION}"
        @@config_data = YAML.load(File.new(File.expand_path("#{DEFAULT_DATA_LOCATION}/configuration.yaml")))
        @@configuration_file_location = File.expand_path("#{DEFAULT_DATA_LOCATION}/configuration.yaml")
        true
      else
        @@configuration_file_location = DEFAULT_DATA_LOCATION
        false
      end
    rescue Exception => e
      raise ConfigurationException
    end
  end

  def self.create_new_configuration_file
    unless File.directory?(DEFAULT_DATA_LOCATION)
      @@logger.info "Creating new directory at: #{DEFAULT_DATA_LOCATION}"
      Dir.mkdir(DEFAULT_DATA_LOCATION)
    end

    @@logger.info "Creating new configuration file at #{DEFAULT_DATA_LOCATION}/configuration.yaml"
    File.open("#{DEFAULT_DATA_LOCATION}/configuration.yaml", "w+") {|f| f << <<-ENDL
      popup_interval: #{DEFAULT_POPUP_INTERVAL}
      always_on_top: #{DEFAULT_ALWAYS_ON_TOP}
      show_help_file_when_opening: #{DEFAULT_SHOW_HELP_WHEN_OPENING}
      default_report_directory: #{DEFAULT_REPORT_DIRECTORY}
    ENDL
    }
    @@configuration_file_location = "#{DEFAULT_DATA_LOCATION}/configuration.yaml"
  end

  def self.load
    @@config_data = {}

    @@logger = Logger.new(STDERR)
    @@first_run = false

    # Need to set values for license so that the systray can render it correctly

    begin
      create_new_configuration_file unless load_from_existing_config_file
    rescue ConfigurationException
      @@logger.error "Error loading configuration file"
    rescue Exception
      @@logger.error "Error creating new configuration file"
    end

    # Add in any entries that don't exist in the config file, this can happen
    # if new config values were added after the config file was created.
    config_file_values_to_add = {}
    self.popup_interval = if @@config_data["popup_interval"].nil?
                            config_file_values_to_add[:popup_interval] = DEFAULT_POPUP_INTERVAL
                          else
                            @@config_data["popup_interval"]
                          end

    @@always_on_top = if @@config_data["always_on_top"].nil?
                        config_file_values_to_add[:always_on_top] = DEFAULT_ALWAYS_ON_TOP
                      else
                        @@config_data["always_on_top"]
                      end

    @@show_help_file_when_opening = if @@config_data["show_help_file_when_opening"].nil?
                                      @@first_run = true
                                      config_file_values_to_add[:show_help_file_when_opening] = DEFAULT_SHOW_HELP_WHEN_OPENING
                                    else
                                      @@config_data["show_help_file_when_opening"]
                                    end

    @@default_report_directory = if @@config_data["default_report_directory"].nil?
                                   config_file_values_to_add[:default_report_directory] = DEFAULT_REPORT_DIRECTORY
                                 else
                                   @@config_data['default_report_directory']
                                 end


    @@report_log_duration_format = if @@config_data["report_log_duration_format"].nil?
                                     #:HHMMSS
                                     :hours
                                   else
                                     @@config_data["report_log_duration_format"]
                                   end

    @@database_location = File.expand_path(@@config_data['database_location'] || DEFAULT_DATA_LOCATION)

    begin
      rev_info = IO.read('revision.txt')
    rescue Exception => e
      rev_info  = "Unavailable"
    end
    case Monkeybars::Resolver.run_location
    when Monkeybars::Resolver::IN_FILE_SYSTEM
      @@logger = Logger.new(STDERR)
    when Monkeybars::Resolver::IN_JAR_FILE
      @@logger.info "Creating new logger at #{Configuration.database_location}/jotbot.log"
      @@logger = Logger.new("#{Configuration.database_location}/jotbot.log", 5, 1024000)
      @@logger.info "JotBot #{JOTBOT_VERSION} #{rev_info} starting up at #{Time.now}"
    end

    update_and_save(config_file_values_to_add) unless config_file_values_to_add.empty?
  end

  def self.update_and_save(configuration_values)
    @@database_location           = configuration_values[:database_location]           if configuration_values.keys.include?(:database_location)
    self.popup_interval           = configuration_values[:popup_interval]              if configuration_values.keys.include?(:popup_interval)
    @@always_on_top               = configuration_values[:always_on_top]               if configuration_values.keys.include?(:always_on_top)
    @@show_help_file_when_opening = configuration_values[:show_help_file_when_opening] if configuration_values.keys.include?(:show_help_file_when_opening)
    @@default_report_directory    = configuration_values[:default_report_directory]    if configuration_values.keys.include?(:default_report_directory)

    configuration = { 'database_location' => @@database_location,
      'popup_interval' =>@@popup_interval,
      'always_on_top' => @@always_on_top,
      'default_report_directory' => @@default_report_directory ,
      'show_help_file_when_opening' => @@show_help_file_when_opening }.to_yaml

    Main.instance.calculate_next_log_time

    begin
      File.open(@@configuration_file_location , 'w'){|f| f << configuration }
    rescue Exception => e
      @@logger.error "Problem saving configuration file"
      @@logger.error e

      raise ConfigurationException, "Problem saving configuration file at #{@@configuration_file_location}"
    end
  end

  def self.default_report_directory
    @@default_report_directory ||= if @@config_data['default_report_directory']
                                     Java::java.io.File.new(File.expand_path( @@config_data['default_report_directory'] ))
                                   else
                                     nil
                                   end
  end

  def self.logger
    @@logger
  end

  def self.database_location
    @@database_location
  end

  def self.popup_interval
    @@popup_interval
  end

  def self.popup_interval_in_seconds
    @@popup_interval_in_seconds
  end

  def self.always_on_top
    @@always_on_top
  end

  def self.show_help_file_when_opening?
    @@first_run || @@show_help_file_when_opening
  end

  def self.check_for_updates?
    true
  end

  def self.license_key_file
    database_location + "/" + DEFAULT_LICENSE_KEY_FILE
  end

  def self.license_version
    @@license_version
  end

  def self.license_version=(version)
    @@license_version = version
  end

  def self.on_linux?
    Config::CONFIG["host_os"] =~ /linux/i
  end

  def self.on_osx?
    Config::CONFIG["host_os"] =~ /darwin/i
  end

  def self.on_windows?
    (Config::CONFIG["host_os"] =~ /^win/i) || (Config::CONFIG["host_os"] =~ /mswin/i)
  end

  def self.report_log_duration_format
    @@report_log_duration_format
  end

  private
  def self.popup_interval=(interval)
    @@popup_interval = interval.to_i
    @@popup_interval_in_seconds = 60 * @@popup_interval
  end
end
