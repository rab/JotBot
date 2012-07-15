class FilterSelectionView < ApplicationView
  set_java_class 'filter_selection.FilterSelection'

  map :view => "selected_report_combo_box.model", :model => :reports, :using => :reports_to_java_array, :ignoring => :item
  map :view => "selected_report_combo_box.model.selected_item", :model => :current_report, :using => [:report_to_string, :default], :ignoring => :item

  def reports_to_java_array(ruby_array)
    javax.swing.DefaultComboBoxModel.new(ruby_array.map { |report| report.name }.to_java(:Object))
  end

  def report_to_string(report)
    report.name
  end
end
