require 'report_model'

__END__


describe ReportModel do
  before :each do
    @it = ReportModel.new
  end
  
  it "nests logs inside of categories" do
    mock_categories = []
    %w{Work Work:TimeTracker}.each_with_index do |name, i|
      mock_categories << OpenStruct.new(:name => name, :id => i)
    end
    
    mock_logs = []
    1.upto 3 do |i|
      mock_logs << OpenStruct.new(:log => "Testing log #{i}", :category => "Work:TimeTracker")
    end
    
    Category.stub!(:find).and_return(mock_categories)
    @it.stub!(:load_log_data).and_return(mock_logs)
    
    @it.load_report_data
    
    work_sub_categories = @it.report_data.find {|e| e.name == "Work"}.sub_categories
    time_tracker_logs = work_sub_categories.find {|e| e.name == "Work:TimeTracker"}.children
    time_tracker_logs.should have(3).logs
  end
  
  it "sorts rows by date and duration" do
    first  = OpenStruct.new :date => Time.utc(2100, 02, 02), :duration => 200
    middle = OpenStruct.new :date => Time.utc(2100, 02, 02), :duration => 100
    last   = OpenStruct.new :date => Time.utc(2100, 02, 03), :duration => 100
    
    rows = @it.send(:sort_rows_by_date_and_duration, ([middle, last, first]))
    
    rows[0].should == first
    rows[1].should == middle
    rows[2].should == last
  end
  
  it "detects repeating logs" do
    log = mock('log', :start_time => Time.utc(2100, 02, 02), :name => 'Work', :text => 'Testing TimeTracker!')
    log.stub!(:category).and_return(log)
    
    row_same = mock('row', :date => Time.utc(2100, 02, 02), :category => 'Work', :log => 'Testing TimeTracker!')
    row_different_day = mock('row', :date => Time.utc(2100, 02, 03), :category => 'Work', :log => 'Testing TimeTracker!')
    
    @it.send(:find_existing_row, log, [row_same, row_different_day]).should == row_same
    @it.send(:find_existing_row, log, [row_same]).should == row_same
    @it.send(:find_existing_row, log, [row_different_day]).should be_nil
  end
  
  it "creates rollup entries for repeated logs"
end
