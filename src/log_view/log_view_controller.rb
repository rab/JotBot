require 'filter_selection_controller'

class LogViewController < ApplicationController
  set_model 'LogViewModel'
  set_view 'LogViewView'
  
  add_listener :type => :list_selection, :components => {"report_area.selection_model" => :report_area}

  def load
    filter_controller = FilterSelectionController.create_instance
    add_nested_controller :filter, filter_controller
    filter_controller.on_report_selection_changed { model.load_log_data; update_view }
    filter_controller.open
    model.filter_selection_model = filter_controller.send(:model)
    model.load_log_data
  end
  
  def ok_button_action_performed
    close
  end
  
  def report_area_mouse_clicked(event)
    if 2 == event.click_count && event.button == java.awt.event.MouseEvent::BUTTON1
      if event.source.selected_row > -1
        id = event.source.get_value_at(event.source.selected_row, 5)
        TimelogEditController.instance.open(id)
      end
    end
  end
end