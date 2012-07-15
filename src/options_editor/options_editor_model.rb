require 'configuration.rb'

class OptionsEditorModel
  attr_accessor :popup_interval, :always_on_top

  def initialize
    @popup_interval = Configuration.popup_interval
    @always_on_top = Configuration.always_on_top
  end

  def save
    Configuration.update_and_save :popup_interval => @popup_interval, :always_on_top => @always_on_top
  end
end
