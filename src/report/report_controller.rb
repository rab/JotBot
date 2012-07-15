require 'timelog_edit_controller'
require 'report_editor_controller'
require 'filter_selection_controller'

class ReportController < ApplicationController
  set_model 'ReportModel'
  set_view 'ReportView'

  add_listener :type => :list_selection, :components => {'report_table.selection_model' => :report_table}

  def load
    filter_controller = FilterSelectionController.create_instance
    add_nested_controller :filter, filter_controller
    filter_controller.on_report_selection_changed { load_report_data }
    filter_controller.open
    model.filter_selection_model = filter_controller.send(:model)
    load_report_data
  end
  
  def export_button_action_performed
    begin
      transfer[:export_type] = view_transfer[:export_type]
      signal :get_export_path
      model.export_to(transfer[:export_path], transfer[:export_type])
    rescue UserCanceledError; end
  end
  
  def ok_button_action_performed
    close
  end
  
  def report_table_mouse_clicked(event)
    if 2 == event.click_count && event.button == java.awt.event.MouseEvent::BUTTON1
      TimelogEditController.instance.open(view_state.transfer[:selected_log_id]) if view_state.transfer[:selected_log_id].kind_of? Integer
    end
  end

  def position
    signal :position_details do |struct|
      struct
    end
  end
  
private
  def load_report_data
    Thread.new do
      signal :show_busy_indicator
      model.load_report_data
      signal :hide_busy_indicator
      
      on_edt do
        update_view
      end
    end
  end
end
