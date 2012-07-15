class LicenseKeyModel
  attr_accessor :license_key, :valid_license, :status, :expiration_date
  
  def initialize
    @license_key = ""
    @valid_license = false
    @status = ""
    @expiration_date = nil
  end

  def nice_expiration_date
    # Yeah, it's view stuff, but it's expedient
    return '' unless @expiration_date 
    @expiration_date.strftime("%B %d, %Y")
  end
end