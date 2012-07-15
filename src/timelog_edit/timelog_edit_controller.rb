require 'timelog_base_controller'

class TimelogEditController < TimelogBaseController
  set_model 'TimelogEditModel'
  set_view 'TimelogEditView'

  def load(id)
    model.load_catagories

    unless id.nil?
      model.populate_from_log_id(id)
    else
      model.populate_from_defaults
    end
  end
  
  def log_button_action_performed
    update_all_model_properties
    if continue_saving_record?
      model.save
      TimelogController.instance.current_log_details = {:category => model.selected_category, :billable => model.billable, :message => model.message, :details => model.details}
      close
    end
  end

private
  # Also used by ensure_end_time_is_after_start_time in timelog_base_controller
  def update_all_model_properties
    update_model(view_model, :start_time, :end_time, :message, :selected_category, :billable, :details)
  end
end
