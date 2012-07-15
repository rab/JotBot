# This spec file blocks the spec runner from completing
__END__
require 'system_tray_controller'

describe SystemTrayController do
  before :each do
    @it = SystemTrayController.instance
  end
  
  after :each do
    @it.close
  end
  
  it "invokes the time log callback when 'Log an entry now' is clicked" do
    block = mock('block')
    block.should_receive(:call)
    @it.open(block)
    @it.log_now_menu_item_action_performed
  end  
end
