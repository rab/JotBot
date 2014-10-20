class ReportEditorView < ApplicationView
  set_java_class 'report_editor.ReportEditor'

  map :view => "report_name.text", :model => :name

  nest :sub_view => :filters, :using => [:add_to_list, :remove_from_list]

  def load
    set_frame_icon 'images/jb_clock_icon_16x16.png'
    @row_count = 0
    report_filter_rows.remove_all
    move_to_center
  end

  def add_to_list(nested_view, nested_component, model, transfer)
    @row_count += 1
    report_filter_rows.get_layout.rows = @row_count if report_filter_rows.get_layout.rows < @row_count
    report_filter_rows.add nested_component
    report_filter_rows.validate
  end

  def remove_from_list(nested_view, nested_component, model, transfer)
    @row_count -= 1

    report_filter_rows.get_layout.rows = @row_count if @row_count >= 6
    report_filter_rows.remove nested_component
    report_filter_rows.validate
    report_filter_rows.repaint
  end
end
