require 'report_controller'
require 'log_view_controller'
require 'category_editor_controller'
require 'options_editor_controller'
require 'about_controller'
require 'help_controller'

class SystemTrayController < ApplicationController
  set_model 'SystemTrayModel'
  set_view 'SystemTrayView'
  
  def load
    model.next_update_text = "Next update at: "
  end
 
  def next_prompt_time=(time)
    model.next_update_text = "Next update at: #{time.strftime('%I:%M %p').downcase}"
    update_view
  end
  
  def log_now_menu_item_action_performed
    TimelogEditController.instance.open(nil)
  end
  
  def view_logs_menu_item_action_performed
    LogViewController.instance.open
  end
  
  def report_menu_item_action_performed
    repaint_while do
      ReportController.instance.open
    end
  end

  def register_menu_item_action_performed
    repaint_while do
      LicenseKeyController.instance.open( :usage => :register_now  )
    end
  end
  
  def category_editor_menu_item_action_performed
    CategoryEditorController.instance.open
  end
 
  def options_menu_item_action_performed
    OptionsEditorController.instance.open
  end
 
  def about_menu_item_action_performed
    AboutController.instance.open
  end
  
  def exit_menu_item_action_performed
    Main.exit
  end
  
  def help_menu_item_action_performed
    HelpController.instance.open
  end
end
