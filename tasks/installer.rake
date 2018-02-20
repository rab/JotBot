require 'fileutils'

require 'pp'

def installed_makensis?
  `which makensis`.to_s.strip.empty? ? false : true
end


namespace :installer do

  #  desc "Package up the app as a self-extracting Unix installation script."
  #  task :unix => ['rawr:jar'] do 
  #    warn "Now packing up Skywire ..."
  #    unless File.exist?('/tmp') && File.directory?('/tmp')
  #      warn "You need to run this on a Unixy box with a '/tmp' directory."
  #      exit
  #    end
  #
  #    dev_root = File.expand_path(File.dirname(__FILE__) + '/..')
  #    
  #    installer_script = "#{dev_root}/#{'skywire_installer_script'}-#{script_version_number}.sh"
  #
  #    File.delete(installer_script) if File.exist?(installer_script)
  #    temp_dir_name = "/tmp/skywire_installer_#{Time.new.to_i}"
  #    Dir.mkdir temp_dir_name
  #    warn "Copy contents of  #{dev_root}/package/deploy/ to #{temp_dir_name} for installer ..."
  #    
  #    FileUtils.cp_r  "#{dev_root}/package/deploy/.", temp_dir_name
  #    raise "Did not copy over required files!" unless File.exist?("#{temp_dir_name}/lib/jruby-complete.jar") 
  #
  #    File.cp "#{dev_root}/scripts/decompress", temp_dir_name
  #    File.cp "#{dev_root}/scripts/installer.rb", temp_dir_name
  #
  #    Dir.chdir temp_dir_name
  #    sh  "tar czf #{dev_root}/payload.tar.gz ./*"
  #    Dir.chdir dev_root 
  #    sh "cat #{dev_root}/scripts/decompress payload.tar.gz > #{installer_script}"
  #    File.delete 'payload.tar.gz'
  #    FileUtils.remove_dir temp_dir_name
  #  end

  desc "Make an installer for OS X"
  task :mac => 'rawr:bundle:app' do
    require './src/version'

    puts "Creating Mac installer"
    volume_name = "JotBot"
    image_file_name = "JotBot.dmg"

    require './src/version'
    versioned_image_file_name = "JotBot-#{JOTBOT_VERSION}-temp.dmg"
    FileUtils.cp image_file_name, versioned_image_file_name
    # this mounts the dmg
    sh "hdiutil attach #{versioned_image_file_name}"
    FileUtils.rm_rf("/Volumes/#{volume_name}/JotBot.app")
    FileUtils.cp_r "#{Rawr::Configuration.current_config.osx_output_dir}/JotBot.app", "/Volumes/#{volume_name}/JotBot.app"

    sh "hdiutil detach /Volumes/#{volume_name}"
    sh "hdiutil convert #{versioned_image_file_name} -format UDZO -o #{versioned_image_file_name.gsub("-temp", "")}"
    FileUtils.rm(versioned_image_file_name)
    #FileUtils.mv(versioned_image_file_name.gsub("-temp", ""), "#{Rawr::Options.data.osx_output_dir}/#{versioned_image_file_name.gsub("-temp", "")}")
    FileUtils.mv(versioned_image_file_name.gsub("-temp", ""), "#{Rawr::Configuration.current_config.osx_output_dir}/#{versioned_image_file_name.gsub("-temp", "")}")
  end



  task :winconfig do
     #Rawr::Options.data.compile_ruby_files=false

    require 'pp'
    File.open( "rawr_options1.txt", 'wb'){ |f|
      f.puts  "rawr options \n" + Rawr::Configuration.current_config.pretty_inspect
    }
  end

  desc 'Make an installer for Windows'
  task :win => [ :winconfig,  'rawr:clean', 'rawr:bundle:exe', :copy_windows_icon] do


    require './src/version'
    require 'pp'
    File.open( "rawr_options2.txt", 'wb'){ |f|
      #f.puts  "rawr options \n" + Rawr::Options.data.pretty_inspect
      f.puts  "rawr options \n" + Rawr::Configuration.current_config.pretty_inspect
    }


    puts "Creating Windows installer"

    if Platform.instance.using_unix?
      if installed_makensis?
        # We want to use the installed binary
        sh "makensis make-installer.nsi"
      else
        # Use the local app
        sh "export NSISDIR=#{Dir::pwd}/tools/nsis; tools/nsis/makensis make-installer.nsi"
      end
    else
      sh 'tools\nsis\makensis.exe make-installer.nsi'
    end
    #FileUtils.mv "JotBot Installer.exe", "#{Rawr::Options.data.windows_output_dir}/JotBot-#{JOTBOT_VERSION}-Installer.exe"
    FileUtils.mv "JotBot Installer.exe", "#{Rawr::Configuration.current_config.windows_output_dir}/JotBot-#{JOTBOT_VERSION}-Installer.exe"
  end

  task :copy_windows_icon do
    #File.copy(Rawr::Options.data.windows_icon_path, Rawr::Options.data.windows_output_dir)
    puts "Rawr::Configuration = #{Rawr::Configuration::OPTIONS.pretty_inspect}"
    File.copy(Rawr::Configuration.current_config.windows_icon_path, Rawr::Configuration.current_config.windows_output_dir)
  end
end
