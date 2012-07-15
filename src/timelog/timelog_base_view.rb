#include_class 'org.jdesktop.swingx.autocomplete.AutoCompleteDecorator'
include_class 'java.util.HashSet'
include_class 'java.awt.KeyboardFocusManager'
include_class 'java.awt.AWTKeyStroke'
include_class 'java.util.Calendar'

class TimelogBaseView < ApplicationView
  def enable_tab_navigation
    forward_set = HashSet.new([AWTKeyStroke.getAWTKeyStroke('pressed TAB')])
    backward_set = HashSet.new([AWTKeyStroke.getAWTKeyStroke('shift pressed TAB')])
    log_details.setFocusTraversalKeys(KeyboardFocusManager::FORWARD_TRAVERSAL_KEYS, forward_set)
    log_details.setFocusTraversalKeys(KeyboardFocusManager::BACKWARD_TRAVERSAL_KEYS, backward_set)
  end
  
  def populate_category_list(categories)
    #AutoCompletingComboBoxModel.new(category, categories.keys)
    javax.swing.DefaultComboBoxModel.new(categories.keys.to_java(:Object))
  end
  
  def populate_time_combo_boxes
    time_array = []

    ['am', 'pm'].each do |time_of_day|
      ([12] + (1..11).to_a).each do |hour|
        (0..59).each do |minute|
          time_array << "#{hour}:#{sprintf("%02d", minute)} #{time_of_day}"
        end
      end
    end
    
    start_time_combo_box.model = javax.swing.DefaultComboBoxModel.new(time_array.to_java(:Object))
    end_time_combo_box.model = javax.swing.DefaultComboBoxModel.new(time_array.to_java(:Object))
  end

  def set_previous_log_entries(model, transfer)
    log.disable_handlers :item do
      log.remove_all_items
      model.previous_messages.each {|message| log.add_item message}
    end
  end
  
  def date_button_action_performed
    date_picker_panel.collapsed = date_picker_panel.collapsed? ? false : true
  end
  
  def details_button_action_performed
    log_details_panel.collapsed = !log_details_panel.collapsed?
  end

  def set_log_details_content_and_visibility details
    if details.strip.empty?
      log_details_panel.animated = false
      log_details_panel.collapsed = true
      log_details_panel.animated = true
      @main_view_component.pack
    end
    details
  end

  def done_animating_pane event
    repack_main_view_component if ('animationState' == event.property_name) and ('expanded' == event.new_value or 'collapsed' == event.new_value)
  end
  
  alias_method :date_picker_panel_property_change, :done_animating_pane
  alias_method :log_details_panel_property_change, :done_animating_pane
  
  def combo_box_changed(event)
    return unless event.state_change == java.awt.event.ItemEvent::SELECTED
    validate
  end
  
  alias_method :end_time_combo_box_item_state_changed, :combo_box_changed
  alias_method :start_time_combo_box_item_state_changed, :combo_box_changed
    
  def validate
    error_found = false
    
    if log.editor.editor_component.text.strip.empty?
      set_border_error_coloring_for log
      error_found = true
    else
      clear_border_error_coloring_for log
    end

    if category.editor.editor_component.document.get_text(0, category.editor.editor_component.document.length).strip.empty?
      set_border_error_coloring_for category
      error_found = true
    else
      clear_border_error_coloring_for category
    end
    
    if start_time_combo_box.visible && end_time_combo_box.visible
      start_date = Calendar.instance
      start_date.time = start_date_picker.date
      end_date = Calendar.instance
      end_date.time = end_date_picker.date
      if strings_to_date_time("#{start_date.get(Calendar::YEAR)}-#{start_date.get(Calendar::MONTH)}-#{start_date.get(Calendar::DAY_OF_MONTH )}", start_time_combo_box.selected_item) >= strings_to_date_time("#{end_date.get(Calendar::YEAR)}-#{end_date.get(Calendar::MONTH)}-#{end_date.get(Calendar::DAY_OF_MONTH )}", end_time_combo_box.selected_item)
        set_border_error_coloring_for start_time_combo_box
        set_border_error_coloring_for end_time_combo_box
        error_found = true
      else
        clear_border_error_coloring_for start_time_combo_box
        clear_border_error_coloring_for end_time_combo_box
      end
    end
    log_button.enabled = !error_found
  end

  alias_method :log_insert_update, :validate
  alias_method :log_remove_update, :validate
  alias_method :category_insert_update, :validate
  alias_method :category_remove_update, :validate
  alias_method :start_date_picker_action_performed, :validate
  alias_method :end_date_picker_action_performed, :validate
  
  def show_category_prompt(model, transfer)
    result = javax.swing.JOptionPane.showConfirmDialog(@main_view_component, 
            "The category #{model.selected_category} does not exist, create it and any of its new parent categories?", 
            'Create a new category?',
            javax.swing.JOptionPane::YES_NO_OPTION)
    yield(result)
  end
  
  def get_current_category_text(incorrect_view_value)
    # category.selected_item doesn't work correctly when the current text has been edited
    category.editor.editor_component.text
  end
  
  def get_current_log_text(incorrect_view_value)
    # category.selected_item doesn't work correctly when the current text has been edited
    log.editor.editor_component.text
  end
  
  def update_billable_value(model, transfer)
    billable.selected = transfer[:billable]
  end
  
  def reload_configuration(model, transfer)
     @main_view_component.always_on_top = Configuration.always_on_top
  end
  
  def repack_main_view_component#(model, transfer)
    @main_view_component.pack
  end
  
  def set_on_top
    @main_view_component.always_on_top = Configuration.always_on_top
  end
end
