require 'singleton'
# require 'configuration'
require 'openssl'
require 'base64'
require 'date'

class LicenseManager
  include Singleton

  PUBLIC_KEY = <<-END_KEY
-----BEGIN RSA PUBLIC KEY-----
MIIBCgKCAQEA0efT8Ku60n/ZgdjzSYjiZec2mD7l+L7YuNMbQB+4MpdZz1evQwQ6
D37K5Fa37h9cgva/YQo3CGGEzCMAMm0+8MZAhSE36MIyi3dOAtsSnvXkUGvulYv1
Xt0yYJVVhlshXPR3wfRyORIlyp9aSt+npYPLHWVcbO7VXrulfydIg+Cwa6U2PiNy
JiJnQuOqXkPmrd3GmdlngOKhqspIeIk9P7A5rmPdirPLUNUAjXVGw071qUNZei/C
GUzcFK3hCbcf17lM8oXi3SrHfz2wTacC9OCZAqRDp8e9avgn3z7FyZJBe9ybGVXl
U4wk+t0gM+hXo9BQNDyp0ptG5+ZWIPKVuwIDAQAB
-----END RSA PUBLIC KEY-----
END_KEY

  attr_reader :expiration_date
  attr_accessor :private_key_path

  def initialize
    @public_key = OpenSSL::PKey::RSA.new PUBLIC_KEY
    @expiration_date = nil
    @private_key_path = private_key_path
    @encoded_key = nil
  end

  def encoded_key= key
    @encoded_key = key
  end

  def private_key_path= private_key_path
    @private_key_path = private_key_path
    @private_key = OpenSSL::PKey::RSA.new(File.read private_key_path) 
  end 

  def expiration_date 
    return @expiration_date unless @expiration_date.nil?
    raise "Cannot check for epiration date without license text." if @encoded_key.nil?
    valid_license_text? @encoded_key
    @expiration_date
  end

  # Validates encode file contents, and stores encode value in @encoded_key
  def valid_license_file? license_key_file
    return false unless File.exists?(license_key_file)  

    begin
      LOGGER.info "Loading license key file: #{license_key_file}"
      @encoded_key  = File.read(license_key_file)
      LOGGER.info "Decrypting license key file"
      valid_license_text?(@encoded_key)
    rescue => e
      LOGGER.fatal "Error loading or decrypting license file"
      LOGGER.fatal e
      LOGGER.fatal e.backtrace
      false
    end
  end

  def license_can_expire?
    !@expiration_date.nil?
  end

  def validate_license text
    valid = true
    message = 'Valid license key'

    plain_text = decrypt_text text
    LOGGER.info "Validating license: #{plain_text.inspect}"
    return [false, 'License is invalid or corrupt'] if plain_text.nil?

    plain_text.split("\n").each do |line|
      case line
      when /^Name:/

      when /^Email:/

      when /^Company:/

      when /^License Version:/
        license_version = line.split(':')[1].strip.split('.')[0].to_i
        app_version = JOTBOT_VERSION.split('.')[0].to_i

        if app_version > license_version
          valid = false
          message = "This license key is valid for version #{license_version} of JotBot, current version is #{JOTBOT_VERSION}"
        end
      when /^Expiration:/
        expiration = line.split(':')[1].strip
        year, month, day = expiration.split('-')

        begin
          @expiration_date = Date.new(year.to_i, month.to_i, day.to_i)
        rescue ArgumentError => e
          valid = false
          message = 'License is invalid or corrupt'
        end
        
        if @expiration_date < Date.today
          valid = false
          message = "License key expired on #{@expiration_date.strftime("%B %d, %Y")}"
        end
      end
    end
    LOGGER.warn "License is invalid, message: '#{message}'" unless valid
    return [valid, message]
  end

  def valid_license_text?(text)
    validate_license(text).first 
  end

  def generate_signed_text(data)
    encrypted_data = @private_key.private_encrypt(data)
    encoded_data = Base64.encode64(encrypted_data)
  end

  def make_key(user_details, expires=false )
    key = generate_signed_text(data_string(user_details, expires))
    LOGGER.debug  "Have key :\n#{key}"
    key 
  end

  def data_string(user_details, expires=false)
    s = "Name: #{user_details[:full_name]}
Company: #{user_details[:company]}
License Version: #{user_details[:license_version]}  
Email: #{user_details[:email]}"

    s << "\nExpiration: #{user_details[:expiration_date]}" if expires 
    s
  end

  private

  def license_to_hash(text)
    plain_text = decrypt_text(text)
    h = {}
    plain_text.split("\n").each do |line|
      line.strip!
      next if line.empty?
      k,v = line.split(':', 2)
      key = k.downcase
      key.gsub!(' ', '_')
      h[key.intern] = v.to_s.strip
    end
    h
  end

  def decrypt_text(text)
    begin
      decoded_data = Base64.decode64(text)
      @public_key.public_decrypt(decoded_data)
    rescue Java::JavaxCrypto::BadPaddingException => e
      LOGGER.info e
      nil
    rescue Java::JavaLang::ArrayIndexOutOfBoundsException => e
      LOGGER.info e
      nil
    end
  end
end
