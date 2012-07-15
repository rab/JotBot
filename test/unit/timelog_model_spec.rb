require 'timelog_model'
require 'time'

__END__


class Category 
  def initialize
    @timelogs =[]
  end
end

require 'time'

describe TimelogModel do
  before :each do
    @log_model = TimelogModel.new
  end


  it "accepts a time interval for its queue" do
    start_time, end_time = Time.local(2007,"jan",1,20,15,1) , Time.local(2007,"jan",1,20,25,1) 
    @log_model.add_to_queue(start_time, end_time)
    @log_model.interval_queue.size.should ==  1
  end

  it "accumlates time intervals in its queue" do
  smin = 0
  start_time, end_time = Time.local(2007,"jan",1,20,smin,1) , Time.local(2007,"jan",1,20,smin+5,1) 
  @log_model.add_to_queue(start_time, end_time)

  smin = 15
  start_time, end_time = Time.local(2007,"jan",1,20,smin,1) , Time.local(2007,"jan",1,20,smin+5,1) 
  @log_model.add_to_queue(start_time, end_time)


  smin = 35
  start_time, end_time = Time.local(2007,"jan",1,20,smin,1) , Time.local(2007,"jan",1,20,smin+5,1) 
  @log_model.add_to_queue(start_time, end_time)

  @log_model.interval_queue.size.should ==  3
end


it "can be assign an end time as a simple string and convert it to  a proper Time object" do
  @log_model.end_time = "8:13pm"
  @log_model.end_time.class.should equal Time

end


it "can be assigned an end time as a simple string and convert it to  a proper Time object with the given time" do
  @log_model.end_time = "8:13pm"
  @log_model.end_time.min.should == 13 
  @log_model.end_time.hour.should ==  20
end

it "has a queue that can be truncated to delete all intervals before the current end time value" do
  # Make a decent queue
  1.upto(4) do |t|
    start_time, end_time = Time.local(2007, "jan", 1, 20, t*10, 0) , Time.local(2007,"jan",1,20, t*10 + 10,0) 
    @log_model.add_to_queue(start_time, end_time)

  end


  @log_model.interval_queue.size.should ==  4

  start_time, end_time = Time.local(2007, "jan", 1, 20, 10, 0) , Time.local(2007,"jan",1,20, 30 ,0) 
  @log_model.start_time = start_time  
  @log_model.end_time = end_time  
  @log_model.update_queue 

  @log_model.interval_queue.size.should ==  2




end



after :each do
  @log_model = nil
end
end

