require 'time'
require 'timelog_base_view'

class TimelogEditView < TimelogBaseView
  set_java_class 'timelog.TimeLogForm'

  raw_mapping :set_date_and_time_components, :get_date_and_time_component_values
#  raw_mapping :set_current_detail, :get_current_detail
  raw_mapping :set_previous_log_entries, nil
  
  map :view => 'category.model', :model => :categories, :using => :populate_category_list
  map :view => 'log.selected_item', :model => :message, :using => [:default, :get_current_log_text], :ignoring => :item
  map :view => 'log_button.text', :model => :new_log, :translate_using => {true => 'Create', false => 'Save', :ignore => 'Log'}
  map :view => 'log.selected_index', :transfer => :log_index
  map :view => 'category.selected_item', :model => :selected_category, :using => [:default, :get_current_category_text], :ignoring => :item
  # WARNING: billable must be mapped after the selected category mapping above, or the billable state will not stick
  map :view => 'billable.selected', :model => :billable
  map :view => 'log_details.text', :model => :details, :using => [:set_log_details_content_and_visibility, :default]
  
  define_signal :name => :show_category_creation_prompt, :handler => :show_category_prompt
  define_signal :name => :update_billable, :handler => :update_billable_value

  add_listener :type => :document, :components => {'log.editor.editor_component.document' => :log}
  add_listener :type => :document, :components => {'category.editor.editor_component.document' => :category}
  
  def on_first_update(model, transfer)
    category.editor.editor_component.document.disable_handlers :document do
      update(model, transfer)
    end
    super
  end


  
  def load
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
 
  def set_date_and_time_components(model, transfer)
    start_date_picker.date = time_to_date(model.start_time)
    end_date_picker.date = time_to_date(model.end_time)
    
    start_time_text = time_to_string(model.start_time)
    end_time_text = time_to_string(model.end_time)
    start_model = start_time_combo_box.model
    end_model = end_time_combo_box.model

    0.upto(start_model.size-1) do |i|
      if start_model.element_at(i) == start_time_text
        start_time_combo_box.selected_index = i
        break
      end
    end

    0.upto(end_model.size-1) do |i|
      if end_model.element_at(i) == end_time_text
        end_time_combo_box.selected_index = i
        break
      end
    end
  end
  
  def get_date_and_time_component_values(model, transfer)
    return if start_date_picker.date.nil? or end_date_picker.date.nil?
    time = string_to_time(start_time_combo_box.selected_item)
    java_date = start_date_picker.date
    model.start_time = Time.local(java_date.year, java_date.month+1, java_date.date, time.hour, time.min, time.sec)
    
    time = string_to_time(end_time_combo_box.selected_item)
    java_date = end_date_picker.date
    model.end_time = Time.local(java_date.year, java_date.month+1, java_date.date, time.hour, time.min, time.sec)
  end
end
