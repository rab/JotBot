class CategoryEditorController < ApplicationController
  set_model 'CategoryEditorModel'
  set_view 'CategoryEditorView'

  def load
    define_handler(:selected_category_insert_update, &method(:validate))
    define_handler(:selected_category_remove_update, &method(:validate))
  end

  def category_list_value_changed(event)
    return if event.value_is_adjusting
    model.selected_category_name = view_state.transfer[:selected_value]
    transfer[:from_category_list] = true
    signal :update_dependant_attributes
    update_view
  end

  def new_button_action_performed
    model.selected_category_primary_id = nil
    signal :prepare_new_category
  end

  def save_button_action_performed

    #   update_model(view_model, :selected_category_billable_status, :selected_category_active_status)
    #   update_model(view_model, :selected_category_name)

    attributes = { :name      => view_model.selected_category_name,
                   :billable  => view_model.selected_category_billable_status,
                   :active    => view_model.selected_category_active_status }

    if view_model.selected_category_primary_id.to_i == 0
      begin
        model.add(attributes)
      rescue Exception => e
        LOGGER.error "Error creating category #{view_model.selected_category_name.inspect}: #{e}"
        raise e
      end
    else
      begin
        model.update(view_model.selected_category_primary_id.to_i, attributes )
      rescue Exception => e
        LOGGER.error "Error saving category #{view_model.selected_category_name}: #{e}"
        raise e
      end
    end

    update_model(view_model, :selected_category_name, :selected_category_billable_status, :selected_category_active_status)
    model.reload_category_data
    update_view
  end


  def validate
    if view_model.selected_category_name.empty?
      transfer[:error] = true
    else
      update_model(view_model, :selected_category_billable_status, :selected_category_active_status)
      update_model(view_model, :selected_category_name )
      model.update_dependant_attributes
    end
    signal :update_attribute_status
  end
end
