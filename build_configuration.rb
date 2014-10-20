require 'lib/ruby/platform'

configuration do |c|
  c.project_name = 'JotBot'
  c.output_dir = 'package'
  c.main_ruby_file = 'main'
  c.main_java_file = 'org.rubyforge.rawr.Main'

  c.source_dirs = ['src', 'lib/ruby']
  c.source_exclude_filter = [/\.form/]

  c.compile_ruby_files = false
  #c.compile_ruby_files_exclude = [/builder\.rb/]

  #c.java_lib_files = (Dir.glob('lib/java/*.jar') + Dir.glob('lib/java/jdic/*.jar')).reject {|file| [/getdown\.jar/, /ant\.jar/, /samskivert\.jar/].any? {|regex| regex =~ file}}
  c.java_lib_files = (Dir.glob('lib/java/*.jar') + Dir.glob('lib/java/jdic/*.jar')).reject {|file| [/getdown\.jar/, /ant\.jar/, /samskivert\.jar/].any? {|regex| regex =~ file}}
  c.java_lib_dirs = []
  c.files_to_copy = (Dir.glob('lib/java/jdic/**/*') - Dir.glob('lib/java/jdic/*.jar')).reject {|file| File.directory? file}

  c.target_jvm_version = 1.6
  # c.minimum_windows_jvm_version = 1.6
  c.jars[:data] = { :directory => 'data/images', :location_in_jar => 'images', :exclude => /tray/}
  c.jars[:help_files] = { :directory => 'help'}

  c.windows_icon_path = File.expand_path('data/icons/jotbot.ico')
  c.mac_icon_path = File.expand_path('data/icons/jotbot.icns')
end
