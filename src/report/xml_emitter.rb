require 'builder'
require 'time_helpers'

class XmlEmitter

  include Neurogami::TimeHelpers

  def emit_from_report_data(report_data, file)
    xml = Builder::XmlMarkup.new(:target => file, :indent => 2)
    xml.instruct!(:xml, :encoding => "UTF-8")
    xml.report do
      report_data.each do |category|
        emit_item(xml, category)
      end
    end
    xml
  end
 
  def emit_item(xml, item)
    if (item.name.nil? || item.name.empty?)
      emit_log xml, item
    else
      emit_category xml, item
    end
  end
  
  def emit_category(xml, category)
    xml.category do
      xml.name  category.name
      xml.duration( {:format => 'hours_decimal'}, category.duration )
      category.sub_categories = [] if category.sub_categories.nil?
      (category.children + category.sub_categories).each do |item|
        emit_item xml, item
      end
    end
  end
  
  def emit_log(xml, log)
    duration = hours_to_hours_minutes_seconds log.duration

    xml.log do
      xml.category log.category
      xml.date     log.date
      xml.duration( {:format => 'hh:mm:ss'}, duration  )
      xml.log      log.log
      xml.billable log.billable
    end
  end
end
