$LOAD_PATH.unshift File.dirname(__FILE__)
require 'logger'
# Initial logger to be used by bootstrap, it is replaced with a file logger below
LOGGER = Logger.new(STDERR)

require 'rbconfig'
require 'version'
require 'manifest'

require 'thread.rb'

#===============================================================================
# Platform specific operations, feel free to remove or override any of these
# that don't work for your platform/application

if Configuration.on_osx?
  java.lang.System.setProperty("apple.laf.useScreenMenuBar", "true")

  include_class "com.apple.eawt.Application"
  include_class "com.apple.eawt.ApplicationListener"
  require 'about_controller'

  class ApplicationHandler
    include ApplicationListener
    def handleAbout(event)
      event.handled = true
      AboutController.instance.open
    end

    def handleQuit(event)
      event.handled = true
      Main.exit
    end

    def method_missing(method, event)
      event.handled = true
    end
  end
  Application.application.add_application_listener(ApplicationHandler.new)
end

# End of platform specific code
#===============================================================================
class Main
  include MessageBox
  include Singleton

  attr_accessor :last_log_time
  attr_reader :next_log_time

  def self.exit(with_error = false)
    exit_status = with_error ? 1 : 0
    if Object.const_defined? :LOGGER
      LOGGER.info "Shutting down at #{Time.now} with status #{exit_status}"
      LOGGER.close
    end
    java.lang.System.exit(exit_status)
  end

  def initialize
    if Configuration.check_for_updates?
      SplashScreenController.instance.show_message "Checking for updates"
      UpdateManager.instance.check
    end

    SplashScreenController.instance.show_message "Validating license"
    unless LicenseManager.instance.valid_license_file?(Configuration.license_key_file)
      LOGGER.info "Invalid license file, prompting for new key"

      LicenseKeyController.instance.open
      while LicenseKeyController.instance.visible?
        sleep 0.1
      end
    else
      LOGGER.info "License file is valid"
    end

    SplashScreenController.instance.show_message "Initializing database"
    DatabaseManager.instance.setup_database

    require_model_dependant_classes

    self.last_log_time = Time.now.round_seconds_down
    @log_screen = nil
    SplashScreenController.instance.close

    if Configuration.show_help_file_when_opening?
      require 'help_controller'
      HelpController.instance.open
    end
  end

  def require_model_dependant_classes
    %w{
      timelog_controller
      report_controller
      log_view_controller
    }.each{|m| require m }
  end

  def run

    SystemTrayController.instance.open

    loop do
      time = Time.now.round_seconds_down
      if (time - @last_log_time) >= Configuration.popup_interval_in_seconds
        add_new_log_interval(@last_log_time, time)
      end
      sleep(1)
    end
  end

  def process_interval(start, stop)
    if @log_screen.nil? or !@log_screen.visible?
      @log_screen = TimelogController.instance
      @log_screen.open start, stop
    else
      @log_screen.add_to_queue start, stop
    end
  end

  def add_new_log_interval(start, stop)
    process_interval(start, stop)
    self.last_log_time = stop
  end

  def last_log_time=(new_time)
    @last_log_time = new_time
    calculate_next_log_time
  end

  def calculate_next_log_time
    @next_log_time = @last_log_time + Configuration.popup_interval_in_seconds
    set_system_tray_log_time_text
  end

  def set_system_tray_log_time_text
    SystemTrayController.instance.next_prompt_time = @next_log_time
  end

end

def show_error_dialog_and_exit(exception, thread=nil)
  bug_reporting = "Please report problems to help@getjotbot.com"
  return if @shutting_down
  @shutting_down = true
  LOGGER.fatal "Error in application"
  LOGGER.fatal("#{exception.class} - #{exception}")
  LOGGER.fatal(exception.message)
  stack_trace = ""
  if exception.kind_of? Exception
    stack_trace = exception.backtrace.join("\n")
  else
    # Workaround for JRuby issue #2673, getStackTrace returning an empty array
    output_stream = java.io.ByteArrayOutputStream.new
    exception.printStackTrace(java.io.PrintStream.new(output_stream))
    stack_trace = output_stream.to_string
  end
  LOGGER.fatal(stack_trace)
  title = "Application Error"
  message = "The application has encountered a critical error, and must shut down."
  message << "\n\n#{bug_reporting}"
  if exception.message =~ /Database may be already in use/i
    title = "Error starting JotBot"
    message = "Another instance of JotBot is already running,\nthis instance of JotBot will now shut down."
    SplashScreenController.instance.close
  end

  javax.swing.JOptionPane.show_message_dialog(nil, message, title, javax.swing.JOptionPane::DEFAULT_OPTION)
  Main.exit(true)
end

#== Main program begin
javax.swing.UIManager.look_and_feel = javax.swing.UIManager.system_look_and_feel_class_name

SplashScreenController.instance.open
SplashScreenController.instance.show_message "Loading configuration"
Configuration.load

LOGGER = Configuration.logger

GlobalErrorHandler.on_error {|exception, thread| show_error_dialog_and_exit(exception, thread) }

begin
  warn "$: = #{$:.sort.join("\n")}"
  #  require 'druby'
  # Invoker.run       # TODO What to do with this?
  Main.instance.run

rescue => e
  show_error_dialog_and_exit(e)
end
