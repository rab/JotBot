include_class 'org.jdesktop.swingx.treetable.DefaultMutableTreeTableNode'
include_class 'org.jdesktop.swingx.treetable.DefaultTreeTableModel'
include_class 'javax.swing.table.TableColumn'
include_class 'javax.swing.table.DefaultTableCellRenderer'
include_class 'org.jruby.javasupport.JavaUtil'
include_class 'javax.swing.SwingUtilities'
include_class 'org.jdesktop.jxlayer.JXLayer'

include_class 'org.jdesktop.jxlayer.plaf.effect.BufferedImageOpEffect'
include_class 'com.jhlabs.image.BlurFilter'

require 'busy_painter_ui'

class ReportTreeTableModel < DefaultTreeTableModel
  def initialize
    super
    @row_data = Hash.new {|h,k| h[k] = ["Name", "", "", ""]}
    @columns = ["Log", "Date", "Time", "Billable"]
  end

  def getColumnCount
    @columns.size
  end

  def getColumnName(index)
    @columns[index]
  end

  def getValueAt(node, column)
    @row_data[node][column]
  end

  def setValueAt(value, node, column)
    @row_data[node][column] = value
  end
end

class UserCanceledError < Exception; end

class ReportView < ApplicationView
  EXPORT_TYPE_TRANSLATION = {:csv => "CSV", :xml => "XML", :pdf => "PDF"}
  set_java_class 'report.ReportForm'
  map :view => "report_table.tree_selection_model", :transfer => :selected_log_id, :using => [nil, :get_selected_id]
  map :view => "export_type_combo_box.selected_item", :transfer => :export_type, :translate_using => EXPORT_TYPE_TRANSLATION
  nest :sub_view => :filter, :using => [:add_filter_selection_panel, :remove_filter_selection_panel]

  raw_mapping :to_table, nil
  raw_mapping :revalidate, nil

  define_signal :name => :get_export_path,     :handler => :prompt_user_for_export_path

  def load
    set_frame_icon 'images/jb_clock_icon_16x16.png'
    report_panel.remove(report_scroll_pane)

    blur_effect = BufferedImageOpEffect.new([BlurFilter.new].to_java('java.awt.image.BufferedImageOp'))
    @report_panel_wrapper = JXLayer.new(report_scroll_pane, BusyPainterUI.new(blur_effect))

    report_panel.add(@report_panel_wrapper)
    report_panel.validate

    report_table.tree_table_model = ReportTreeTableModel.new
    @set_value_at = report_table.tree_table_model.method("setValueAt") #fix for JRuby incorrectly selecting base class version instead of subclass
    move_to_center
  end

  def add_filter_selection_panel(nested_view, nested_component, model, transfer)
    filter_wrapper_panel.remove_all
    filter_wrapper_panel.add(nested_component)

    self.filter_selection_panel = nested_component
  end

  # The report data is loading on a background thread and will call update_view when it completes
  def on_first_update(model, transfer); end

  def to_table(model, transfer)
    root_node = DefaultMutableTreeTableNode.new("root node")
    report_table.tree_table_model.set_root(root_node)

    model.report_data.reverse.each do |row| #we're adding to index 0 each time so go in reverse order
      add_sub_categories(root_node, row)
    end

    set_column_widths
  end

  def revalidate(model, transfer)
    report_scroll_pane.validate
  end

  def get_selected_id(tree_model)
    return nil if tree_model.selection_path.nil?
    tree_model.selection_path.last_path_component.user_object
  end

  define_signal :name => :show_busy_indicator, :handler => :show_busy_spinner
  def show_busy_spinner(model, transfer)
    on_edt { @report_panel_wrapper.ui.locked = true }
  end

  define_signal :name => :hide_busy_indicator, :handler => :hide_busy_spinner
  def hide_busy_spinner(model, transfer)
    on_edt { @report_panel_wrapper.ui.locked = false }
  end

  define_signal :name => :position_details, :handler => :create_position_struct
  Struct.new("Position", :x, :y, :width, :height)
  def create_position_struct(model, transfer)
    yield(Struct::Position.new(x, y, width, height))
  end

  def prompt_user_for_export_path model, transfer
    #  src/report/report_view.rb:115:in `prompt_user_for_export_path': cannot convert instance
    #  of class org.jruby.RubyString to class java.io.File (TypeError)

    file_chooser = Java::javax::swing::JFileChooser.new  "#{Configuration.default_report_directory}"

    #    file_chooser.current_directory = Configuration.default_report_directory

    selected_file = Java::java::io::File.new "#{model.default_export_file.gsub(' ', '_')}.#{transfer[:export_type]}"
    file_chooser.selected_file = selected_file
    result = file_chooser.show_save_dialog @main_view_component
    if Java::javax::swing::JFileChooser::APPROVE_OPTION == result
      transfer[:export_path] = file_chooser.selected_file.absolute_path
    else
      raise UserCanceledError.new "User canceled export file choice."
    end
  end

  private

  def add_logs(category_node, logs)
    logs.reverse.each do |log|
      node = DefaultMutableTreeTableNode.new
      node.user_object = log.database_id if log.children.size < 2
      report_table.tree_table_model.insert_node_into(node, category_node, 0)

      @set_value_at.call(log.log, node, 0)
      @set_value_at.call(log.date.strftime("%B %d, %Y"), node, 1)
      @set_value_at.call(sprintf("%0.2f", log.duration), node, 2)
      @set_value_at.call((true == log.billable ? "yes" : ""), node, 3)
      if log.children.size > 1
        add_logs(node, log.children)
      end
    end
  end

  def add_sub_categories(parent_node, row_object)
    node = DefaultMutableTreeTableNode.new
    report_table.tree_table_model.insert_node_into(node, parent_node, 0)
    @set_value_at.call(row_object.name, node, 0)
    @set_value_at.call(sprintf("%0.2f", row_object.duration), node, 2)
    node.user_object = row_object.name
    add_logs(node, row_object.children)

    row_object.sub_categories.each {|sub_category| add_sub_categories(node, sub_category)}
  end

  def set_column_widths
    column_model = report_table.column_model
    column_model.getColumn(0).setPreferredWidth(300)

    column_model.getColumn(1).setPreferredWidth(160)
    column_model.getColumn(1).setMaxWidth(160)

    column_model.getColumn(2).setMinWidth(75)
    column_model.getColumn(2).setMaxWidth(75)

    column_model.getColumn(3).setMinWidth(50)
    column_model.getColumn(3).setMaxWidth(50)
  end
end
