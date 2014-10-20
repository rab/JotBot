class OptionsEditorView < ApplicationView
  set_java_class 'options_editor.OptionsEditor'

  map :view => 'popup_interval.model.value', :model => :popup_interval, :using => [:to_java_object, :default]
  map :view => 'always_on_top.selected', :model => :always_on_top

  define_signal :name => :error_while_saving, :handler => :show_error_message

  def load
    set_frame_icon 'images/jb_clock_icon_16x16.png'
    move_to_center
  end

  def show_error_message(model, transfer)
    javax.swing.JOptionPane.showConfirmDialog(@main_view_component,
                                              "Error saving configuration file",
                                              "There was an error saving your options to the configuration file",
                                              javax.swing.JOptionPane::INFORMATION_MESSAGE)
  end

  def to_java_object(object)
    Java.ruby_to_java object
  end
end
