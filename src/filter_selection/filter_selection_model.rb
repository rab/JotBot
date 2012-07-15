class FilterSelectionModel
  attr_reader :reports, :current_report
  Struct.new("EmptyReport", :name, :id)
  EMPTY_REPORT = Struct::EmptyReport.new("Add custom filter", -1)
  
  def load_reports
    @reports = Report.dataset.order(:id).all || []
    @reports << EMPTY_REPORT
    @current_report = @reports.first
  end

  def empty_report
    EMPTY_REPORT
  end

  def current_report_is_empty?
    current_report.id == -1
  end
  
  def current_report=(new_report)
    if new_report.kind_of? Report
      @current_report = new_report
    else
      if "Add new report" == new_report
        @current_report = EMPTY_REPORT
      else
        @current_report = @reports.find {|report| report.name == new_report}
      end
    end
  end
end
