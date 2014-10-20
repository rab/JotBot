require 'singleton'
require 'open-uri'
require 'timeout'

class UpdateManager
  include Singleton
  VERSION_FILE = 'version.txt'

  if ENV['JOTBOT_DEV_MODE']
    CURRENT_VERSION_URL = 'http://getjotbot.com/api/current-dev-version'
  else
    CURRENT_VERSION_URL = 'http://getjotbot.com/api/current-version'
  end

  LOGGER.info "Update url: #{CURRENT_VERSION_URL}"

  def process_update_availability
    javax.swing.JOptionPane.showMessageDialog(nil, "There is a new version of JotBot available.\nPlease visit http://www.getjotbot.com/download")
  end

  # See if there is a newer version, and take some action is there is
  def check
    begin
      current_version = JOTBOT_VERSION.gsub('.', '').to_i
      web_version = 0
      timeout(10) do
        open(CURRENT_VERSION_URL, :proxy => nil) do |f|
          web_version = parse_api_data(f.read)[:version]
        end
      end

      LOGGER.info "web version: #{web_version}, current version: #{current_version}"
      if web_version > current_version
        process_update_availability
      else
        LOGGER.info 'JotBot is up to date'
      end
    rescue OpenURI::HTTPError => e
      LOGGER.info 'Could not connect to update web site'
      # Ignore network problems
    rescue SystemCallError => e
      LOGGER.info 'Could not connect to update web site'
    rescue EOFError => e
      LOGGER.info 'Error reading version file information'
    rescue TimeoutError => e
      LOGGER.info 'Connection timed out'
    rescue Exception => e
      LOGGER.warn "An unexpected error in UpdateManager#check: #{e.inspect}"
    end
  end

  def parse_api_data(text)
    text = text.to_s
    text.strip!
    {:version => text.to_i}
  end

  # Previous code that would kick off Getdown.
  # Deprecated until Vista issuesa re resolved
  #def _process_update_availability

  #  result = javax.swing.JOptionPane.showConfirmDialog(nil,
  #        'There is a new version of JotBot available, would you like to install the update?',
  #        'Update available',
  #        javax.swing.JOptionPane::YES_NO_OPTION)
  #  if 0 == result
  #    case Monkeybars::Resolver.run_location
  #    when Monkeybars::Resolver::IN_FILE_SYSTEM
  #      project_dir = File.expand_path(File.dirname(__FILE__) + '/../../')
  #    when Monkeybars::Resolver::IN_JAR_FILE
  #      LOGGER.info "__FILE__ == #{__FILE__}"
  #      project_dir = (File.expand_path(File.dirname(__FILE__) + '/../')).gsub('file:', '').gsub('%20', ' ')
  #      if Configuration.on_windows?
  #        project_dir = project_dir[1..-1] if '/' == project_dir[0..0]
  #      end
  #    end
  #    LOGGER.info "Writing new file #{project_dir}/#{VERSION_FILE} with contents: #{web_version}"
  #    File.open("#{project_dir}/#{VERSION_FILE}", 'w'){|f| f.puts web_version}

  #    if Configuration.on_windows?
  #      LOGGER.info java.lang.System.get_property('java.home')
  #      getdown_command = "\"#{java.lang.System.get_property('java.home')}\\bin\\java\" -jar \"#{project_dir}/lib/java/getdown-pro.jar\" \"#{project_dir}\""
  #    else
  #      getdown_command = "#{java.lang.System.get_property('java.home')}/bin/java -jar #{project_dir}/lib/java/getdown-pro.jar #{project_dir}"
  #    end
  #    LOGGER.info "Executing: #{getdown_command}"
  #    java.lang.Runtime.runtime.exec getdown_command
  #    LOGGER.info 'Done invoking getdown, exiting'
  #    java.lang.System.exit(0)
  #  else
  #    LOGGER.info 'Skipping update'
  #  end
  #end
end
