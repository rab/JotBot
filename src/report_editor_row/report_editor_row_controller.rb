class ReportEditorRowController < ApplicationController
  set_model 'ReportEditorRowModel'
  set_view 'ReportEditorRowView'

  def load(parent, filter)
    @parent = parent
    @filter = filter

    model.from_filter(filter) unless filter.nil?
  end

  def add_label_mouse_released
    @parent.add_new_row
    @parent.update_nested_controller_visibility
  end

  def delete_label_mouse_released
    @parent.remove_row(self)
    @parent.update_nested_controller_visibility
  end

  def update_component_visibility
    transfer[:delete] = true
    transfer[:add] = false

    if @parent.filter_controllers.size == 1
      transfer[:delete] = false
      transfer[:add] = true
    elsif @parent.filter_controllers.last == self
      transfer[:add] = true
    end
    signal :update_component_visibility
  end

  def filter_model
    clear_view_state
    view_model
  end
end
