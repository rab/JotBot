class ReportEditorRowView < ApplicationView
  set_java_class 'report_editor_row.ReportEditorRow'

  raw_mapping :initial_type_value, nil
  map :view => "type_combo_box.selected_item", :model => :type, :translate_using => {'date' => 'Date', 'category' => 'Category', 'billable' => 'Billable'}
  map :view => "specifier_combo_box.selected_item", :model => :selected_parameter
  map :view => "parameter_text_field.text", :model => :text_parameter, :using => [:from_text_parameter, :to_text_parameter]

  # TODO: Implement within/not within for report filter generation, then
  #       these can be turned back on.
  #  DATE_SELECTION_TYPES_WITH_A_TEXT_VALUE = ['within', 'not within']
  DATE_SELECTION_TYPES_WITH_A_TEXT_VALUE = []
  #  DATE_SELECTION_TYPES_WITH_A_LABEL_VALUE = ['within', 'not within']
  DATE_SELECTION_TYPES_WITH_A_LABEL_VALUE = []
  DATE_SELECTION_TYPES_WITH_A_DATE_VALUE = ['is', 'is not', 'after', 'before']

  def load
    date_picker.editor.editable = false
  end

  def initial_type_value(model, transfer)
    setup_type_combo_box_values(model.type, model.selected_parameter)
  end

  def setup_type_combo_box_values(type, specifier = nil)
    specifier_combo_box.model.remove_all_elements

    case type.downcase
    when "date"
      (ReportEditorRowModel::DEFINED_DATE_TYPES + ReportEditorRowModel::ADDITIONAL_SELECTION_DATE_TYPES)
    when "category"
      ReportEditorRowModel::CATEGORY_SELECTION_TYPES
    when "billable"
      ReportEditorRowModel::BILLABLE_SELECTION_TYPES
    end.each {|type| specifier_combo_box.model.add_element type }

    specifier_combo_box.model.selected_item = specifier unless specifier.nil?
  end

  def to_text_parameter(parameter_text_value)
    if "Date" == type_combo_box.selected_item && DATE_SELECTION_TYPES_WITH_A_DATE_VALUE.member?(specifier_combo_box.selected_item)
      calendar = java.util.Calendar.instance
      calendar.time = date_picker.date
      day = calendar.get(java.util.Calendar::DATE)
      month = calendar.get(java.util.Calendar::MONTH) + 1
      year = calendar.get(java.util.Calendar::YEAR)
      "#{year}/#{month}/#{day}"
    else
      parameter_text_value
    end
  end

  def from_text_parameter(text_parameter)
    if match = /(\d+)\/(\d+)\/(\d+)/.match(text_parameter)
      date = java.util.Calendar.instance
      date.set(match[1].to_i, match[2].to_i-1, match[3].to_i)
      date_picker.date = date.time
      ""
    else
      text_parameter
    end
  end

  def type_combo_box_item_state_changed(event)
    return unless event.state_change == java.awt.event.ItemEvent::SELECTED
    setup_type_combo_box_values event.item
  end

  def specifier_combo_box_item_state_changed(event)
    return unless event.state_change == java.awt.event.ItemEvent::SELECTED

    case type_combo_box.selected_item
    when "Date"
      parameter_text_field.visible = DATE_SELECTION_TYPES_WITH_A_TEXT_VALUE.member? event.item
      qualifier_label.visible = DATE_SELECTION_TYPES_WITH_A_LABEL_VALUE.member? event.item
      date_picker.visible = DATE_SELECTION_TYPES_WITH_A_DATE_VALUE.member? event.item
    when "Category"
      parameter_text_field.visible = true
      qualifier_label.visible = false
      date_picker.visible = false
    when "Billable"
      parameter_text_field.visible = false
      qualifier_label.visible = false
      date_picker.visible = false
    end
  end

  define_signal :name => :update_component_visibility, :handler => :process_visibility_settings
  def process_visibility_settings(model, transfer)
    transfer.keys.each do |key|
      case key
      when :add
        add_label.visible = transfer[:add]
      when :delete
        delete_label.visible = transfer[:delete]
      when :label
        qualifier_label.visible = transfer[:label]
      end
    end
  end
end
