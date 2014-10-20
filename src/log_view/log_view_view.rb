class LogViewView < ApplicationView
  set_java_class 'log_view.LogView'

  raw_mapping :setup_table, nil
  nest :sub_view => :filter, :using => [:add_filter_selection_panel, :remove_filter_selection_panel]

  def load
    set_frame_icon 'images/jb_clock_icon_16x16.png'
    move_to_center
  end

  def setup_table(model, transfer)
    table = report_area.model
    table.remove_row(0) while table.row_count > 0

    model.logs.each do |log|
      table.add_row([log.text, log.category.name, log.duration_in_hours.to_s, log.start_time.strftime('%m/%d/%y %I:%M %p'), log.billable ? 'yes' : '', log.id].to_java(java.lang.Object))
    end
  end

  def add_filter_selection_panel(nested_view, nested_component, model, transfer)
    filter_wrapper_panel.remove_all
    filter_wrapper_panel.add(nested_component)

    self.filter_selection_panel = nested_component
  end
end
