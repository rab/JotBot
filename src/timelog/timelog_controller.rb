require 'timelog'
require 'category'
require 'timelog_base_controller'

class TimelogController < TimelogBaseController
  set_model 'TimelogModel'
  set_view 'TimelogView'

  add_listener :type => :key, :components => {"category.editor.editor_component" => :category}
  add_listener :type => :item, :components => [:log]

  @@category = nil
  @@billable = nil
  @@message = nil
  @@details = nil

  def load(start_time, end_time)
    raise "Cannot load the Timelog controller with nil time values" if start_time.nil? || end_time.nil?
    model.load_catagories
    add_to_queue(start_time, end_time)
  end

  def log_button_action_performed
    update_model(view_state.model, :message, :details, :selected_category, :billable, :end_time_select)
    adjust_model_for_end_time_select
    if continue_saving_record?
      @@category = view_state.model.selected_category
      @@billable = view_state.model.billable
      @@message = view_state.model.message
      @@details = view_state.model.details
      model.save
      handle_closing
    end
  end

  def adjust_model_for_end_time_select
    unless view_state.model.end_time_select.nil?
      model.end_time = view_state.model.end_time_select
    end
  end

  def handle_closing
    if model.interval_queue.empty?
      close
    else
      interval_update
    end
  end

  def add_to_queue(start_time, end_time)
    model.add_to_queue( start_time, end_time )
    set_model_with_latest_interval(start_time, end_time)
    signal :process_interval_set_for_rendering
  end

  def interval_update
    transfer[:interval_queue] = model.interval_queue
    signal :process_interval_set_for_rendering
  end

  def current_log_details
    {:category => @@category, :billable => @@billable, :message => @@message, :details => @@details}
  end

  def current_log_details=(details)
    @@category = details[:category]
    @@billable = details[:billable]
    @@message = details[:message]
    @@details = details[:details]
  end

  private
  # Also used by ensure_end_time_is_after_start_time in timelog__base_controller
  def update_all_model_properties
    update_model(view_state.model, :message, :details, :selected_category, :billable, :end_time_select)
  end

  def set_model_with_latest_interval(start_time, end_time)
    model.start_time = start_time
    model.end_time = end_time
    model.selected_category = @@category unless @@category.nil?
    model.billable = @@billable unless @@billable.nil?
    model.message = @@message unless @@message.nil?
    model.details = @@details unless @@details.nil?
  end
end
