class ReportEditorModel
  attr_accessor :name, :filters
  
  def initialize
    @filters = []
  end
  
  def report=(report)
    @report = report
    @name = report.name
  end
end