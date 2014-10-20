class HelpView < ApplicationView
  set_java_class 'help.Help'

  def load
    set_frame_icon 'images/jb_clock_icon_16x16.png'

    class_loader = org.rubyforge.rawr.Main.java_class.class_loader
    url = Java::javax::help::HelpSet.find_help_set(class_loader, "helpset.hs")
    help_set = Java::javax::help::HelpSet.new(class_loader, url)
    viewer = Java::javax::help::JHelp.new(help_set)
    @main_view_component.add(viewer, Java::java::awt::BorderLayout::CENTER)
    viewer.preferred_size = Java::java::awt::Dimension.new(740,460)

    @main_view_component.pack
    move_to_center
  end
end
