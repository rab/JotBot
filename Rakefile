require 'rake'
gem 'rawr'
require 'rawr'
require 'spec/rake/spectask'
# require 'cucumber/rake/task'


# Notes for source release:
#  Tasks relating to key generation, and JotBot Web site stuff, were removed.
#  The public version of JotBot  should not require a license key, but if that
#  has not been cleaned up then a license key should be included someplace.
#
#

Dir.glob("tasks/**/*.rake").each do |rake_file|
  load File.expand_path(File.dirname(__FILE__) + "/" + rake_file)
end


task 'rawr:bundle:app' => :create_digest
task 'rawr:bundle:exe' => :create_digest

desc "Run all unit specs"
Spec::Rake::SpecTask.new do |t|
  t.libs << File.expand_path(File.dirname(__FILE__) + "/src")
  t.libs << File.expand_path(File.dirname(__FILE__) + "/test/unit")
  t.spec_files = FileList['test/unit/**/*_spec.rb']
  t.ruby_opts = ['-rtime', '-Isrc'] # Super class error unless we force loading time before any AR stuff
  t.verbose = true
  t.spec_opts = ['--color']
end

task 'rawr:bundle:app' => [:write_revision_info, :basic_bundle]
task 'rawr:bundle:exe' => [:write_revision_info, :basic_bundle]

task :write_revision_info do 
  version_rb_file = 'package/jar/revision.txt'

  warn "Writing repo revision info!"

  show = `git show`
  hash = show.split( "\n").first
  hash.sub!('commit', '')
  hash.strip!

  File.open(version_rb_file , 'wb') { |f| f.puts hash }

  puts "Last commit hash: #{hash}"
end

desc 'make a jar'
task 'rawr:jar' => [:write_revision_info]

task :basic_bundle => [ 'rawr:jar'] do
  require 'src/version'
end

desc "Generate digest.txt file for Getdown"
task :create_digest => [ 'rawr:jar'] do
  require 'src/version'
  require 'java'

  $CLASSPATH << File.expand_path(File.dirname(__FILE__) + '/lib/java/getdown.jar')
  $CLASSPATH << File.expand_path(File.dirname(__FILE__) + '/lib/java/samskivert.jar')
  $CLASSPATH << File.expand_path(File.dirname(__FILE__) + '/lib/java/ant.jar')

end


def dot_the_verion v
  v = v.to_s
  v.split('').join('.')
end


task :default => ['rawr:clean', 'rawr:jar']
