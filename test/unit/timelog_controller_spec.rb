require 'timelog_controller'
require 'time'

__END__


describe TimelogController do
  before :each do
    @it = TimelogController.instance
  end




  after :each do
    @it.close
  end
end
