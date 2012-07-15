class SplashScreenController < ApplicationController
  set_model 'SplashScreenModel'
  set_view 'SplashScreenView'
  
  def show_message(message)
    model.message = message
    update_view
  end
end
