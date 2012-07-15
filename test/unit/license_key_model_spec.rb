require 'src/license_key/license_key_model'

__END__



def signed_license_key
"-----BEGIN PGP MESSAGE-----
Version: BCPG v1.39

owJ4nJvAy8zAxHj9oyJ/xbqOh4ynXZP4vJzifTKTU/OKU/VKKko8MtJZjIyMatKA
oMbI2MSoxtAICIEIIpSVmJta7AAmk4oyS0r0kvNzuTqWsDAwMjHwsTIBtbOyyxQn
5+cnVTJwcQrAbJoTzfxPUarI+q3axCQ+S86gwohdq7VPbCxY4bBRRHfV2qCmZWI/
ckuyD9U/V1OYUVyRsibv1IP5T3e8rmBw0RW9I/Tqpe+tSwl3T1evcDQxZpxzPoXr
2nKbeSt0zE9XXmG6dUnxw1lxIQ3fB7smL/2t/fnmtbh9S/xyWBhP37ov6XKHhyW+
aPNhvrI7APLWZ+w=
=Pxxr
-----END PGP MESSAGE-----"

end

def jotbot_license_key
"-----BEGIN JOTBOT KEY-----
Version: JotBotKey v1.39

owJ4nJvAy8zAxHj9oyJ/xbqOh4ynXZP4vJzifTKTU/OKU/VKKko8MtJZjIyMatKA
oMbI2MSoxtAICIEIIpSVmJta7AAmk4oyS0r0kvNzuTqWsDAwMjHwsTIBtbOyyxQn
5+cnVTJwcQrAbJoTzfxPUarI+q3axCQ+S86gwohdq7VPbCxY4bBRRHfV2qCmZWI/
ckuyD9U/V1OYUVyRsibv1IP5T3e8rmBw0RW9I/Tqpe+tSwl3T1evcDQxZpxzPoXr
2nKbeSt0zE9XXmG6dUnxw1lxIQ3fB7smL/2t/fnmtbh9S/xyWBhP37ov6XKHhyW+
aPNhvrI7APLWZ+w=
=Pxxr
-----END JOTBOT KEY-----"

end

def license
  "222|ffff|2342|12121121|ffff|james@jamesbritt.com"
end



describe LicenseKeyModel do
  before :each do
    @license_key_model = LicenseKeyModel.new
  end

  it "accepts a signed license key" do
    lambda{ @license_key_model.signed_license_key = signed_license_key }.should_not raise_error(Exception)
  end

  it 'extracts the actual key text from any wrapping text' do
    wrapped_key = "some cruft and such\n" + jotbot_license_key + "\nMore cruft"
    @license_key_model.signed_license_key = wrapped_key 
    @license_key_model.extract_key_from_any_wrapping_text
    @license_key_model.extract_key_from_any_wrapping_text.should == jotbot_license_key
  end

  it "converts a standard PGP key to a JotBot key" do
    jb_key = @license_key_model.convert_pgp_key_to_jotbot_key(signed_license_key)
    jb_key.split("\n").first.should == LicenseKeyModel::KEY_WRAPPING_TEXT.first[LicenseKeyModel::KEY_WRAPPING_JOTBOT]  
  end


  
  it "converts a JotBot key to a PGP key" do
    jb_key = @license_key_model.convert_jotbot_key_to_pgp_key(jotbot_license_key)
    jb_key.split("\n").first.should == LicenseKeyModel::KEY_WRAPPING_TEXT.first[LicenseKeyModel::KEY_WRAPPING_PGP]  
  end


  it "verfies the signature " do
    def @license_key_model.public_key_file_path
      "#{File.expand_path(File.dirname(__FILE__))}/../../pub2.asc"
    end
    @license_key_model.signed_license_key = signed_license_key 
      lambda{ @license_key_model.process_key }.should_not raise_error(LicenseKeyError)
    @license_key_model.get_decrypted_license_text.should == license
  end


  it "raised LicenseKeyError when given a bad key" do
    @license_key_model.signed_license_key = "some bogus text"
    lambda{ @license_key_model.process_key }.should raise_error(LicenseKeyError)
  end
end
