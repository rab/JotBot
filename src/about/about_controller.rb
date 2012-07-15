class AboutController < ApplicationController
  set_view 'AboutView'
  
  def close_button_action_performed
    close
  end
end
