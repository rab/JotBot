require 'java'

# Load subdirectories in src onto the load path
Dir.glob(File.expand_path(File.dirname(__FILE__) + "/**")).each do |directory|
  $LOAD_PATH << directory unless directory =~ /\.\w+$/ #File.directory? is broken in current JRuby for dirs inside jars
end

#===============================================================================
# Monkeybars requires, this pulls in the requisite libraries needed for
# Monkeybars to operate.

$: << File.expand_path(File.dirname(__FILE__))

require 'resolver'


case Monkeybars::Resolver.run_location
when Monkeybars::Resolver::IN_FILE_SYSTEM
  add_to_classpath monkeybars_jar( '../lib/java/' )
end

require 'monkeybars'
require 'application_controller'
require 'application_view'

# End of Monkeybars requires
#===============================================================================
#
# Add your own application-wide libraries below.  To include jars, append to
# $CLASSPATH, or use add_to_classpath, for example:
#
# $CLASSPATH << File.expand_path(File.dirname(__FILE__) + "/../lib/swing-layout-1.0.3.jar")
#
# or
#
# add_to_classpath "../lib/swing-layout-1.0.3.jar"

require 'rubygems'

case Monkeybars::Resolver.run_location
when Monkeybars::Resolver::IN_FILE_SYSTEM
  add_to_classpath "../lib/java/jruby-complete.jar"
  add_to_classpath "../lib/java/jdic/jdic.jar"
  add_to_classpath "../lib/java/jdbc_adapter_internal.jar"
  add_to_classpath "../lib/java/swingx-0.9.3.jar"
  add_to_classpath "../lib/java/swing-layout-1.0.3.jar"
  add_to_classpath "../lib/java/jxlayer.jar"
  add_to_classpath "../build/classes"
  add_to_classpath "../package/bin"
  $LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../lib/java")
when Monkeybars::Resolver::IN_JAR_FILE
  $LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../../lib/java").gsub("file:", "")
end

$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../lib/ruby")
