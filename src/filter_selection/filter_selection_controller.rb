class FilterSelectionController < ApplicationController
  set_model 'FilterSelectionModel'
  set_view 'FilterSelectionView'

  def load
    model.load_reports
  end

  def on_report_selection_changed(&block)
    @report_selection_callback = block
  end

  def selected_report_combo_box_item_state_changed(event)
    return unless event.state_change == java.awt.event.ItemEvent::SELECTED
    model.current_report = event.item

    if model.current_report == FilterSelectionModel::EMPTY_REPORT
      edit_button_action_performed
    else
      @report_selection_callback.call
    end
  end

  def add_label_mouse_released
    ReportEditorController.instance.open(model.empty_report) do |report|
      model.load_reports
      unless report.nil?
        model.current_report = report
      end
      @report_selection_callback.call
    end
  end

  def edit_button_action_performed
    ReportEditorController.instance.open(model.current_report) do |modified_report|
      model.load_reports
      unless modified_report.nil?
        model.current_report = modified_report
      end
      @report_selection_callback.call
    end
  end
end
