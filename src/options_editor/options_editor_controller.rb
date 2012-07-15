class OptionsEditorController < ApplicationController
  set_model 'OptionsEditorModel'
  set_view 'OptionsEditorView'

  def save_action_performed
    update_model(view_state.model, :popup_interval, :always_on_top)
    begin
      model.save
    rescue ConfigurationException => e
      LOGGER.error e
      LOGGER.error e.backtrace
      signal :error_while_saving
    end      
    close
  end
end
