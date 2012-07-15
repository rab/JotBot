require 'timelog_base_controller'
require 'time'
__END__

describe TimelogBaseController do
  before :each do
    @controller = TimelogBaseController.instance
  end
  
  after :each do
    @controller.close
  end
  
  it "makes sure to continue saving the record"
  
end
