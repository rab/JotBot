require 'fastercsv'
require 'time_helpers'

class CsvEmitter
  include Neurogami::TimeHelpers

  def windows_newline
    #"\n\r"
    "\n"
  end

  def duration_report_format log
    case Configuration.report_log_duration_format
    when :hours
      seconds_to_hours_decimal log.duration_seconds
    when :HHMMSS
      seconds_to_hours_minutes_seconds( log.duration_seconds )
    else
      seconds_to_hours_decimal log.duration_seconds
    end
  end

  def faster_emit_from_report_data report_data, csv=''
    if report_data.respond_to? :each
      report_data.each do |category|
        faster_emit_from_report_data(category, csv)
      end
    else
      report_data.sub_categories = [] if report_data.sub_categories.nil?
      (report_data.children + report_data.sub_categories).each do |log|
        if log.children.empty?
          csv  << FasterCSV.generate_line( [log.category, log.log, log.date, duration_report_format(log), log.billable] )
        else
          faster_emit_from_report_data(log, csv)
        end
      end
    end
    csv
  end

  #def emit_from_report_data(report_data, csv='')
  #  if report_data.respond_to? :each
  #    report_data.each do |category|
  #      emit_from_report_data(category, csv)
  #    end
  #  else
  #    report_data.sub_categories = [] if report_data.sub_categories.nil?
  #    (report_data.children + report_data.sub_categories).each do |log|
  #      if log.children.empty?
  #        csv << escape(log.category)
  #        delimit(csv)
  #        csv << escape(log.log)
  #        delimit(csv)
  #        csv << escape(log.date)
  #        delimit(csv)
  #        csv << escape(log.duration)
  #        delimit(csv)
  #        csv << escape(log.billable)
  #        end_record(csv)
  #      else
  #        emit_from_report_data(log, csv)
  #      end
  #    end
  #  end
  #  csv
  #end

  def end_record(csv)
    csv << windows_newline
  end

  def delimit(csv)
    csv << ','
  end

  def escape(csv)
    "#{csv}"
  end
end
