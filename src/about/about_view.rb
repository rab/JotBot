class AboutView < ApplicationView
  set_java_class 'about.About'
  
  def load
    set_frame_icon 'images/jb_clock_icon_16x16.png'
    version.text = JOTBOT_VERSION
    move_to_center
  end
end
