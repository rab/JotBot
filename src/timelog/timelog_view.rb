require 'timelog_base_view'
require 'debuggery'

class TimelogView < TimelogBaseView
  include Neurogami::Debuggery

  set_java_class 'timelog.TimeLogForm'

  raw_mapping :set_previous_log_entries, nil

  map :view => "category.model", :model => :categories, :using => :populate_category_list
  #  map :view => "log_details.text", :model => :details, :using => [:set_log_details_content_and_visibility, :default]
  map :view => "log_details.text", :model => :details, :using => [nil, :default]
  map :view => "log.selected_item", :model => :message, :using => [:default, :get_current_log_text], :ignoring => :item
  map :view => "category.selected_item", :model => :selected_category, :using => [:to_category_selected_item, :get_current_category_text], :ignoring => :item
  map :view => "billable.selected", :model => :billable
  map :view => "end_time_combo_box.selected_item", :model => :end_time_select, :using => [:time_to_string, :string_to_time]
  map :view => "log.selected_index", :transfer => :log_index

  def to_category_selected_item category
    category
  end

  raw_mapping :set_title, nil

  define_signal :name => :interval_update,                      :handler => :process_interval_set
  define_signal :name => :add_to_queue,                         :handler => :add_to_queue
  define_signal :name => :process_interval_set_for_rendering,   :handler => :process_interval_set
  define_signal :name => :show_category_creation_prompt,        :handler => :show_category_prompt
  define_signal :name => :reload_configuration,                 :handler => :reload_configuration
  define_signal :name => :update_billable,                      :handler => :update_billable_value

  add_listener :type => :document, :components => {'log.editor.editor_component.document' => :log}
  add_listener :type => :document, :components => {'category.editor.editor_component.document' => :category}

  def editable_load
    date_picker_panel.animated = false
    date_picker_panel.collapsed = true
    date_picker_panel.animated = true

    start_time_label.visible = false
    start_time_combo_box.visible = true
    end_time_label.visible = false
    end_time_combo_box.visible = true

    populate_time_combo_boxes
    enable_tab_navigation
    set_on_top

    start_date_picker.editor.enabled = false
    end_date_picker.editor.enabled = false

    move_to_center
    set_frame_icon 'images/jb_clock_icon_16x16.png'
    #enable_auto_complete_for_combo_box :category
    @main_view_component.pack
  end

  def load
    set_frame_icon 'images/jb_clock_icon_16x16.png'
    date_picker_panel.visible = false
    date_button.visible = false
    log_details_panel.animated = false
    log_details_panel.collapsed = true
    log_details_panel.animated = true
    @main_view_component.pack

    enable_tab_navigation
    set_on_top
    move_to_center
  end

  def on_first_update model, transfer
    begin
      category.editor.editor_component.document.disable_handlers :document do
        super
      end
    rescue Exception => e
      LOGGER.error "Error in on_first_update: #{e.inspect}"
      LOGGER.error e.backtrace
      raise e
    end
  end

  def show
    @main_view_component.focusable_window_state = false
    super
    @main_view_component.focusable_window_state = true
    @main_view_component.repaint
  end

  def process_interval_set model, transfer
    raise Exception, 'Empty interval' if model.interval_queue.nil? || model.interval_queue.empty?

    if 1 == model.interval_queue.size
      start_time = model.interval_queue.first.first
      end_time = model.interval_queue.first.last
      render_single_interval model, transfer
    else
      render_mulitple_intervals model, transfer
    end
    set_on_top
  end

  def swap_in_new_combo_values model
    end_time_combo_box.remove_all_items

    model.interval_queue.each do |interval|
      LOGGER.error "[ #{__FILE__}:#{__LINE__}] Cannot have a nil interval time." if interval.last.nil?
      raise "[ #{__FILE__}:#{__LINE__}] Cannot have a nil interval time." if interval.last.nil?
      end_time_combo_box.model.add_element format_time(interval.last)
    end

    end_time_combo_box.selected_index = end_time_combo_box.item_count-1
  end

  def render_mulitple_intervals model, transfer
    swap_in_new_combo_values model
    model.start_time, model.end_time = model.interval_queue.first.first, model.interval_queue.last.last
    raise "Cannot have empty time values in Timelog view #{__LINE__}." if model.start_time.nil? || model.end_time.nil?
    set_title(model, transfer)
  end

  def render_single_interval model, transfer
    model.start_time, model.end_time = model.interval_queue.first.first, model.interval_queue.first.last
    raise "Cannot have empty time values in Timelog view #{__LINE__}." if model.start_time.nil? || model.end_time.nil?
    set_title(model, transfer)
  end

  def set_title model, transfer
    LOGGER.error "[ #{__FILE__}:#{__LINE__}] Cannot have nil model times in set_title. model: #{model.inspect}"  if (model.start_time.nil? || model.end_time.nil? )
    LOGGER.info " Cannot have nil model times, called  #{caller_method_name}" if (model.start_time.nil? || model.end_time.nil? )
    raise "[ #{__FILE__}:#{__LINE__}] Cannot have nil model times in set_title." if (model.start_time.nil? || model.end_time.nil? )

    if model.interval_queue.nil? || 1 == model.interval_queue.size
      title1.text = 'What did you do from'

      # Code, at times, is getting nil time values from the model
      start_time_label.text = "#{format_time(model.start_time)}"
      end_time_label.text = "#{format_time(model.end_time)}?"

      time_field_visibility(:label, :label)
    else
      title1.text = 'What did you do from'
      start_time_label.text = "#{format_time(model.start_time)}"

      time_field_visibility(:label, :combo_box)
    end
  end

  def format_time time
    # This is exploding because it sometimes gets passed a nil value
    time.strftime('%I:%M %p').downcase
  end

  private
  def time_field_visibility start_field, end_field
    if :label == start_field
      start_time_label.visible = true
      start_time_combo_box.visible = false
    else
      start_time_label.visible = false
      start_time_combo_box.visible = true
    end

    if :label == end_field
      end_time_label.visible = true
      end_time_combo_box.visible = false
    else
      end_time_label.visible = false
      end_time_combo_box.visible = true
    end
  end
end
