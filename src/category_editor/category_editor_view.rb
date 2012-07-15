class CategoryEditorView < ApplicationView
  set_java_class 'category_editor.CategoryEditor'

  map :view => "category_list.selected_value", :transfer => :selected_value, :using => [nil, :default]
  map :view => "selected_category_id.text", :model => :selected_category_primary_id, :using => [:to_string, :to_integer]
  map :view => "billable.selected", :model => :selected_category_billable_status
  map :view => "active.selected", :model => :selected_category_active_status 
  map :view => 'selected_category_text_field.text', :model => :selected_category_name

  raw_mapping :populate_category_list, nil

  define_signal :name => :update_attribute_status, :handler => :update_attribute_status
  define_signal :name => :show_category_deletion_prompt, :handler => :category_deletion_prompt
  define_signal :name => :populate_category_list, :handler => :populate_category_list
  define_signal :name => :prepare_new_category, :handler => :prepare_new_category 
  define_signal :name => :update_dependant_attributes, :handler => :update_dependant_attributes 

  def load
    set_frame_icon 'images/jb_clock_icon_16x16.png'
    move_to_center
  end

  def prepare_new_category(model, transfer)
    selected_category_text_field.text = "New Category"
    selected_category_text_field.request_focus
    selected_category_id.text = '0'
  end

  def populate_category_list(model, transfer)
    category_list.disable_handlers(:list_selection) do
      category_list.list_data = model.category_names.map.to_java(:Object)
      category_list.selected_index = category_list.get_next_match(model.selected_category_name, 0, Java::javax::swing::text::Position::Bias::Forward)
    end
    selected_category_id.text = model.selected_category_primary_id.to_s 
  end

  def update_dependant_attributes(model, transfer)
    model.update_dependant_attributes
  end

  def update_attribute_status(model, transfer)
    if transfer[:error]
      set_background_error_coloring_for selected_category_text_field
      save_button.enabled = false
    else
      clear_background_error_coloring_for selected_category_text_field
      save_button.enabled = true
    end
  end


end
