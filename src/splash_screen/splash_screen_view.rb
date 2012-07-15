class SplashScreenView < ApplicationView
  set_java_class 'splash_screen.SplashScreen'
  
  map :view => 'status_message.text', :model => :message
  
  def load
    set_frame_icon 'images/jb_clock_icon_16x16.png'
    move_to_center
    version_label.text = "Version: #{JOTBOT_VERSION}"
  end
end
