require 'rbconfig'

class Platform

  @@operating_system = RbConfig::CONFIG['host_os']

  class << self

    def using_unix?
      @using_unix ||= !using_windows?
    end

    def using_windows?
      @using_windows ||= (@@operating_system =~ /^win|mswin/i)
    end

    def using_linux?
      @using_linux ||= (@@operating_system =~ /linux/)
    end

    def using_mac?
      @using_mac ||= (@@operating_system =~ /darwin/)
    end

    def argument_delimiter
      using_windows? ? ';' : ':'
    end

    def using_mac_64bit?
      using_mac? && is_java_64bit?
    end

    def simple_java_version
      return $simple_java_version unless $simple_java_version.nil?
      $java_verion ||= java.lang.System.get_property('java.version')
      major, minor, rest = $java_verion.split('.', 3)
      $simple_java_version ||= major + '.' + minor
    end

    def is_java_64bit?
      # Is this reliable  TODO Check this
      RbConfig::CONFIG['target_cpu'] =~ /64/
    end

    def we_are_running_on_1_6_64bit?
      is_java_64bit? && simple_java_version == '1.6'
    end

    def should_use_java16_jdic?
      we_are_running_on_1_6_64bit? || Platform.instance.using_windows?
    end

  end
end
