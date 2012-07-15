require 'java'
require 'pp'
# $:.unshift "~/ngdev"
$here = File.expand_path(File.dirname(__FILE__))

# The idea is to make sure the load path does not inadvertantly have
# locations that depend on some particular machine or installation
def restrict_load_path
 $:.dup.each do |path|
    next if path == '.'
    next if path == $here
    next if path =~ /jruby-complete.jar!/
    $:.delete_if{ |i| i == path } 
 end
end


restrict_load_path

# Load subdirectories in src onto the load path
# TODO: Eventually remove this temporary workaround for http://jira.codehaus.org/browse/JRUBY-3162
# encodings such as %20 are not used correctly as part of Dir.glob
Dir.glob(File.expand_path( $here + '/**/*').gsub('%20', ' ')).each do |directory|
  next if directory =~ /\/builder\//
  next if directory =~ /\/prawn\//
  $: << directory unless directory =~ /\.\w+$/ #File.directory? is broken in current JRuby for dirs inside jars
end
#===============================================================================
# Monkeybars requires, this pulls in the requisite libraries needed for
# Monkeybars to operate.


## File.expand_path fix for launching via Java Web Start
#class File
#  class_eval do
#    class << self
#      alias_method :original_expand_path, :expand_path
#    end
#  end

#  def File.is_jnlp_url?(path)
#    path =~ /^http/i
#  end

#  def File.expand_path(file_name, directory=nil)
#    if is_jnlp_url?(file_name)
#       "./#{file_name.split('jar!/').last}"
#    else
#      original_expand_path(file_name, directory)
#    end
#  end
#end


warn "\n-----------------------------------\n$: = #{$:.sort.join("\n")}\n-----------------------------------\n"

require 'resolver'
require 'platform'

module Kernel
  def simple_java_version
    return $simple_java_version unless $simple_java_version.nil?
    $java_verion ||= java.lang.System.get_property('java.version')
    major, minor, rest = $java_verion.split('.', 3)
    $simple_java_version ||= major + '.' + minor
  end

  def is_java_64bit?
    Platform.is_java_64bit?
  end

  def we_are_running_on_1_6_64bit?
    is_java_64bit? && simple_java_version == '1.6' 
  end

  def should_use_java16_jdic?
     we_are_running_on_1_6_64bit? || Platform.using_windows? 
  end
end


def monkeybars_jar path
  Dir.glob(path).select { |f| f =~ /(monkeybars-)(.+).jar$/}.first
end

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
  add_to_load_path "../lib/ruby"
#  add_to_load_path "../lib/ruby/fastercsv/lib"
 # add_to_load_path "../lib/ruby/prawn/lib"
 # add_to_load_path "../lib/ruby/prawn_layout/lib"
  require 'platform'
  unless should_use_java16_jdic?
    add_to_classpath "../lib/java/jdic/jdic.jar"
  end
  add_to_classpath "../lib/java/jdbc_adapter_internal.jar"
  add_to_classpath "../lib/java/swingx-0.9.3.jar"
  add_to_classpath "../lib/java/swing-layout-1.0.3.jar"
  add_to_classpath "../lib/java/jxlayer.jar"
  add_to_classpath "../lib/java/bcprov-jdk14-139.jar"
  add_to_classpath "../lib/java/bcmail-jdk14-139.jar"
  
  add_to_load_path "../../lib/ruby"
  add_to_load_path "../../lib/java"
  add_to_load_path "../build/classes"

when Monkeybars::Resolver::IN_JAR_FILE
  add_to_load_path "prawn/lib"
  add_to_load_path "prawn_layout/lib"
  add_to_load_path "builder/lib"
end

add_to_load_path "../lib/java"

require 'platform'
require 'openssl.rb'
require 'splash_screen_controller'
require 'h2_date_fix'
require 'time_extensions'
require 'database_manager'
require 'system_tray_controller'
require 'message_box'
require 'license_key_controller'
require 'update_manager'


res = require 'license_manager'

raise "Failed to require 'license_manager' !" unless res
lm = LicenseManager.instance
