# require 'view_positioning'

class LicenseKeyView < ApplicationView
  include Monkeybars::View::Positioning

  set_java_class 'license_key.LicenseKey'

  map :view => 'license_key_text.text', :model => :license_key, :using => [nil, :default]
  map :view => 'ok_button.enabled', :model => :valid_license, :using => [:default, nil]
  map :view => 'status_label.text', :model => :status, :using => [:default, nil]

  define_signal :name => :set_initial_license_key, :handler => :update_license_contents
  define_signal :name => :set_usage_text, :handler => :set_usage_text
  define_signal :name => :hand_cursor, :handler => :hand_cursor

  def load
    set_frame_icon 'images/jb_clock_icon_16x16.png'
    move_to_center
    set_default_text
  end

  def update_license_contents(model, transfer)
    license_key_text.document.disable_handlers(:document) do
      license_key_text.text = model.license_key
    end
  end

  # Likely not needed
  def set_default_text
    #link_label.text = "<html><h4>Welcome to JotBot</h4></html>"
#    link_label.text = "<html>Click here to purchase a JotBot license key: <a href='http://buy.getjotbot.com'>buy.getjotbot.com</a></html>"
#    body_label.text = "<html>Please copy and paste the license key that was emailed to you when you purchased JotBot<br><br>
 #       If you did not recieve your key or if you need to request your key again, please email support@getjotbot.com </html> "
  end


  

=begin
Cursor cur = new Cursor ( Cursor.WAIT_CURSOR ) ;
?.setCursor ( cur ) ;

Cursor cur2 = new Cursor ( Cursor.CROSSHAIR_CURSOR ) ;
?.setCursor ( cur2 ) ;

Cursor cur3 = new Cursor ( Cursor.HAND_CURSOR ) ;

Image img = getImage( getCodeBase(), "pic.gif"  );
Cursor cuscur =
 Toolkit.getDefaultToolkit().createCustomCursor
  ( img, new Point(0,0), "ourkersr" );
?.setCursor( cuscur );

=end
    # http://www.java-tips.org/java-se-tips/javax.swing/how-to-change-mouse-cursor-during-mouse-over-action-on-hyper.html 
  def hand_cursor(model, transfer)

#   cursor = java.javax.awt.Cursor.new( java.javax.awtCursor::HAND_CURSOR ) 

  end

  def set_usage_text(model, transfer)
    # If we're using a more complex form with one set of standard text we can skip this dynamic text assignment
    #case transfer[:usage]
    #when :register_now
    #  link_label.text = "<html>Click here to purchase a JotBot license key: <a href='http://buy.getjotbot.com'>buy.getjotbot.com</a></html>"
    #  body_label.text = "<html>Please copy and paste the license key that was emailed to you when you purchased JotBot<br><br>
    #    If you did not recieve your key or if you need to request your key again, please email support@getjotbot.com</html> "
    #else
    #  set_default_text
    #end
  end
end
