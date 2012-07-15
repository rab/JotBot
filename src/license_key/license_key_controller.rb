class LicenseKeyController < ApplicationController
  set_model 'LicenseKeyModel'
  set_view 'LicenseKeyView'
  set_close_action :close

  add_listener :type => :document, :components => {"license_key_text.document" => "license_key_text"}

  def load(options = {})
    @options = options 
    if File.exists? Configuration.license_key_file
      # Need is in order to validate key
      model.license_key = File.read(Configuration.license_key_file)
    else
      model.license_key = ""
    end
    validate_key_text
    # Clear the license text until we figure out how to
    # prevern a hdieous Java bug
    #     JDK Bug causing NPE's if we have the previous license text in the text area
    model.license_key = ""

    signal :set_initial_license_key

    if @options[:usage]
      transfer[:usage] = @options[:usage]
      signal :set_usage_text
    end

    @saved_license_key = false
  end

  def unload
    # Close the app unless we have been loaed with a valid key in place.
    if (@options[:usage] && @options[:usage] == :register_now) || @saved_license_key
      return
    else
      java.lang.System.exit(0)
    end
  end

  # We have some labels that need to act as links.
  # The current plan is that the lable text should be only the link.
  # On the one hand, if we can grab that URL from the label we can avoid having
  # to keep the view and actual ink in sync
  # On the other, do we want the controller to do that?
  def buy_link_label_mouse_released
    url = Java::java::net::URL.new("http://www.getjotbot.com/buy")
    Java::org::jdesktop::jdic::desktop::Desktop.browse(url)
  end

  def trial_link_label_mouse_entered
   signal :hand_cursor
  end

  def trial_link_label_mouse_released
    url = Java::java::net::URL.new("http://www.getjotbot.com/ks/trial")
    Java::org::jdesktop::jdic::desktop::Desktop.browse(url)
  end

  def license_key_text_insert_update
    update_model(view_model, :license_key)
    validate_key_text
    update_view
  end
  alias_method :license_key_text_remove_update, :license_key_text_insert_update

  def ok_button_action_performed
    if @options[:usage]
      case @options[:usage]
      when :register_now
        unless trim_email_contents(view_model.license_key).strip.empty?
          default_ok
        end
      else 
        default_ok
      end
    else
      default_ok
    end
    close
  end

  def default_ok
    LOGGER.info "Saving license key to #{Configuration.license_key_file}"
    file = File.new(Configuration.license_key_file, 'w')
    file << trim_email_contents(view_model.license_key)
    file.close
    @saved_license_key = true
  end

  private
  def validate_key_text
    valid, message = LicenseManager.instance.validate_license(trim_email_contents(model.license_key))
    if valid
      model.valid_license = valid
      model.expiration_date = LicenseManager.instance.expiration_date if LicenseManager.instance.license_can_expire?
      model.status = "License is valid. It will expire on #{model.nice_expiration_date}" if model.expiration_date
    else
      model.valid_license = valid
      model.status = message
    end
  end

  # Gets rid of anything other than the actual license key by looking for 
  # lines starting with === and removing everything above the first one
  # and below the second one. What is in-between is assumed to be the
  # license key.
  def trim_email_contents(text)
    if text =~ /^===/
      lines = text.split("\n")
      in_key = false
      lines.reject do |line|
        if line =~ /^===/
          in_key = !in_key
          true
        else
          !in_key
        end
      end.join("\n")
    else
      text
    end
  end
end
