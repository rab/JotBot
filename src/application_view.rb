include_class 'javax.swing.event.ListDataEvent'

# Implements the same interface as DefaultComboBoxModel but filters list based on
# the contents of the JComboBox's text field
class AutoCompletingComboBoxModel
  include Java::javax::swing::ComboBoxModel
  include Java::javax::swing::event::DocumentListener

  # Methods from ComboBoxModel interface
  def getSize
    @filtered_items.size
  end
  alias_method :get_size, :getSize

  def getSelectedItem
    @selected_item
  end
  alias_method :get_selected_item, :getSelectedItem

  def setSelectedItem(item)
    puts "setSelectedItem(#{item})"
    @selected_item = item if @filtered_items.member? @selected_item

    @component.editor.item = item
  end
  alias_method :set_selected_item, :setSelectedItem

  def getElementAt(index)
    @filtered_items[index]
  end
  alias_method :get_element_at, :getElementAt

  def addListDataListener(listener)
    @listeners << listener
  end
  alias_method :add_list_data_listener, :addListDataListener

  def removeListDataListener(listener)
    @listeners.delete listener
  end
  alias_method :remove_list_data_listener, :removeListDataListener

  # Methods mimicing DefaultComboBoxModel interface
  def addElement(item)
    puts "addElement(#{item})"
    @items << item
    filter_list
  end
  alias_method :add_element, :addElement

  def getIndexOf(item)
    puts "getIndexOf(#{item})"
    (@filtered_items.index item) || -1
  end
  alias_method :get_index_of, :getIndexOf

  def insertElementAt(item, index)
    puts "insertElementAt(#{item}, #{index})"
    @items.insert(index, item)
    filter_list
  end
  alias_method :insert_element_at, :insertElementAt

  def removeAllElements
    puts "removeAllElements"
    @items = []
    filter_list
  end
  alias_method :remove_all_elements, :removeAllElements

  def removeElement(item)
    puts "removeElement(#{item})"
    @items.delete item
    filter_list
  end
  alias_method :remove_element, :removeElement

  def removeElementAt(index)
    puts "removeElementAt(#{index})"
    @items.delete_at(index)
    filter_list
  end
  alias_method :remove_element_at, :removeElementAt


  def initialize(combo_box, item_array = [])
    @items = item_array
    @filtered_items = item_array
    @selected_item = @items.first
    @component = combo_box
    @component.editor.editor_component.document.add_document_listener(self)
    @listeners = []
  end

  def changedUpdate(event);
    puts "changed"
  end

  def insertUpdate(event)
    puts event.type
    p event
    filter_list_and_show_popup
  end

  def removeUpdate(event)
    puts "received remove event from: #{event.document.inspect}"
    puts "@component.editor.editor_component.document: #{@component.editor.editor_component.document.inspect}"
    puts event.type
    p event
    filter_list_and_show_popup
  end

  private
  def filter_list
    original_list_size = @component.item_count
    original_text = @component.editor.editor_component.document.get_text(0, @component.editor.editor_component.document.length)
    puts "original text: #{original_text}"
    text = original_text.downcase
    @filtered_items = @items.map do |category|
      index = category.downcase.index text
      if index.nil?
        nil
      else
        [index, category]
      end
    end.compact.sort.map { |index_and_category| index_and_category[1] }

    @filtered_items = @items if @filtered_items.empty?
    javax.swing.SwingUtilities.invoke_later(Monkeybars::TaskProcessor::Runnable.new do
                                              @component.editor.editor_component.document.disable_handlers :document do
                                                alert_listeners :contents_changed, 0, @items.length - 1
                                                @component.editor.item = original_text unless 0 == original_list_size
                                              end
                                            end)
  end

  def filter_list_and_show_popup
    javax.swing.SwingUtilities.invoke_later(Monkeybars::TaskProcessor::Runnable.new do
                                              @component.hide_popup
                                            end)

    filter_list

    javax.swing.SwingUtilities.invoke_later(Monkeybars::TaskProcessor::Runnable.new do
                                              @component.show_popup
                                            end)
  end

  def alert_listeners(type, start_index, end_index)
    case type
    when :interval_added
      @listeners.each do |listener|
        listener.interval_added ListDataEvent.new(self, ListDataEvent::INTERVAL_ADDED, start_index, end_index)
      end
    when :interval_removed
      @listeners.each do |listener|
        listener.interval_removed ListDataEvent.new(self, ListDataEvent::INTERVAL_REMOVED, start_index, end_index)
      end
    when :contents_changed
      @listeners.each do |listener|
        listener.contents_changed ListDataEvent.new(self, ListDataEvent::CONTENTS_CHANGED , start_index, end_index)
      end
    end
  end
end

class ApplicationView < Monkeybars::View
  #  def enable_auto_complete_for_combo_box(component_name)
  #    component = self.send(component_name)
  #    component.model = AutoCompletingComboBoxModel.new(component) #, @autocomplete_current_categories[component_name])
  #  end

  def time_to_date(time)
    # This breaks if passed a JavaSQL timestamp unless we catch that ...
    case time.class.to_s
    when "Java::JavaSql::Timestamp"
      milliseconds = time.time + (time.nanos / 1000000)
      java.util.Date.new(milliseconds)
    else
      java.util.Date.new(time.to_i * 1000)
    end
  end

  def time_to_string(time)
    # We may get Java SqlTimestamps ...
    return nil unless time.kind_of? Time
    hour = time.hour % 12
    hour = 12 if 0 == hour
    time.strftime("#{hour}:%M %p").downcase
  end

  def string_to_time(text)
    # The string being passed is almost certinaly coming from a Swing component, which is using 0-base month indices.
    # Sadly, Ruby does not agree that 0 == January
    # It will asplode if given 0 for a month.
    # However, this method only cares about the time, so we can much the date part.
    #
    return text if text.nil?
    text.strip!
    # Sometimes we get just the time.
    # TODO If "just the time" is OK, then perhaps we should simply
    # strip any date part, rather than try to fix it? Think about it.
    text = reparse_date_string(text) if is_date_string?(text)
    Time.parse(text)
  end


  def to_integer(value)
    value.to_i
  end

  def to_string(value)
    "#{value}"
  end

  def strings_to_date_time(date_text, time_text)
    string_to_time("#{date_text} #{time_text}")
  end

  def set_border_error_coloring_for(component)
    component.setBorder(javax.swing.border.LineBorder.new(java.awt.Color.new(255, 0, 0), 2, false))
  end

  def set_foreground_error_coloring_for(component)
    @original_foreground_color ||= Hash.new {|h,k| h[k] = nil}
    if @original_foreground_color[component].nil?
      @original_foreground_color[component] = component.foreground
      component.foreground = foreground_error_color_for(component.foreground)
    end
  end

  def clear_border_error_coloring_for(component)
    component.setBorder(nil)
  end

  def clear_foreground_error_coloring_for(component)
    if @original_foreground_color && !@original_foreground_color[component].nil?
      component.foreground = @original_foreground_color[component]
      @original_foreground_color[component] = nil
    end
  end

  def background_error_color_for(component)
    #    java.awt.Color.new(255, 60, 60)
    java.awt.Color.new(component.red,
                       component.green - 80 < 0 ? 0 : component.green - 80,
                       component.blue - 80 < 0 ? 0 : component.blue - 80)
  end

  def foreground_error_color_for(component)
    java.awt.Color.new(component.red + 128 < 255 ? component.red + 128 : 255,
                       component.green,
                       component.blue)
  end

  def set_frame_icon(file)
    @main_view_component.icon_image = Java::javax::swing::ImageIcon.new(Java::org::rubyforge::rawr::Main.get_resource(file)).image
  end

  def is_date_string?(text)
    text =~ /-/
  end

  def reparse_date_string(datetime_str)
    return datetime_str unless is_date_string?(datetime_str)
    date, time, other = datetime_str.split(' ', 3)
    y,m,d = *( date.split('-').map{|s| s.to_i } )
    datetime = "#{y}-#{m+1}-#{d} #{time} #{other}"
  end

end
