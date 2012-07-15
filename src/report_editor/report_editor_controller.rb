require 'report_editor_row_controller'

class ReportEditorController < ApplicationController
  set_model 'ReportEditorModel'
  set_view 'ReportEditorView'

  attr_reader :filter_controllers
  
  def load(current_report, &callback)
    @done_editing_callback = callback
    @filter_controllers = []
    
    if -1 == current_report.id
      @current_report = Report.new(:name => "New Filter")
      filter = ReportFilter.new(:filter_type => "date", :parameter => "today")
      add_new_row filter
    else
      @current_report = current_report
      @current_report.report_filters.each do |filter|
        add_new_row(filter)
      end
    end
    
    model.report = @current_report
    update_nested_controller_visibility
  end
  
  def add_new_row(filter = nil)
    model.filters << filter
    @filter_controllers << ReportEditorRowController.create_instance
    add_nested_controller :filters, @filter_controllers.last
    @filter_controllers.last.open(self, filter)
  end
  
  def remove_row(component)
    @filter_controllers.delete(component).close
    remove_nested_controller :filters, component
  end
  
  def update_nested_controller_visibility
    @filter_controllers.each {|controller| controller.update_component_visibility }
  end
  
  def save_button_action_performed
    filters = @filter_controllers.map {|controller| controller.filter_model.to_filter}
    @current_report.name = view_model.name
    
    LOGGER.info "Saving report #{@current_report.inspect}"
    @current_report.save
    @current_report.report_filters.each{|filter| filter.destroy}
    LOGGER.info "Saving report filters #{filters.inspect}"
    filters.each do |filter|
      @current_report.add_report_filter filter
      filter.save
    end
    
    @done_editing_callback.call(@current_report.name)
    close
  end
  
  def delete_button_action_performed
    if !@current_report.new?
      @current_report.report_filters.each do |filter|
        LOGGER.info "Deleting report filter #{filter.inspect}"
        filter.destroy
      end
    end
    LOGGER.info "Deleting report #{@current_report.inspect}"
    @current_report.destroy
    @done_editing_callback.call(nil)
    close
  end
end