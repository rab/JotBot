module MessageBox
  def show_message_dialog(title, message_text)
    javax.swing.JOptionPane.show_message_dialog(@main_view_component, message_text , title )
  end
end