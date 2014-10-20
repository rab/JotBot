require 'timelog'
require 'category'
require 'ostruct'
require 'report'

class ReportModel
  attr_reader :report_data, :reports
  attr_accessor :current_report
  attr_writer :filter_selection_model

  def load_report_data

    @report_data = []

    categories = Category.dataset.order(:name).all
    begin
      rows = load_log_data
    rescue => e
      puts e
      puts e.backtrace
    end

    categories.find_all {|category| category.name.index(":").nil? }.each do |category|
      category_struct = build_category(categories, rows, category)
      @report_data << category_struct unless (category_struct.sub_categories.empty? and category_struct.children.empty?)
    end
  end

  def default_export_file
    @filter_selection_model.current_report.name
  end

  def report_list_empty?
    return true if @reports.nil? || @reports.empty?
    return true if @reports.size == 1 and  @reports.first.report_id == -1
    false
  end

  def export_to path, exporter
    begin
      LOGGER.info "Create #{exporter} report"
      send "emit_#{exporter}", path
    rescue Exception => e
      LOGGER.error "Error creating #{exporter} report: #{e}"
    end

  end

  def emit_xml path
    require 'xml_emitter'
    File.open(path, "w") do |file|
      XmlEmitter.new.emit_from_report_data(@report_data, file)
    end

  end

  def emit_pdf path
    require 'pdf_emitter'
    PdfEmitter.new.emit_from_report_data(@report_data, path)

  end

  def emit_csv path
    require 'csv_emitter'
    #    export_data = CsvEmitter.new.emit_from_report_data(@report_data)
    faster_export_data = CsvEmitter.new.faster_emit_from_report_data(@report_data)
    File.open(path, "w") do |file|
      #file << export_data
      file.puts faster_export_data
    end
  end

  private

  def load_log_data
    rows = []

    return rows if @filter_selection_model.current_report_is_empty?

    filter, joins = @filter_selection_model.current_report.build_filter

    if filter.empty?
      logs = Timelog.dataset.all
    else
      if joins.empty?
        logs = Timelog.filter(filter).all
      else
        dataset = Timelog.filter(filter)
        joins.each do |join|
          dataset = dataset.inner_join(join[0], join[1])
        end
        logs = dataset.all
      end
    end

    logs.each do |log|
      if row = find_existing_row(log, rows)
        row.children << wrap_log_in_struct(log, false)
        row.duration += log.duration_in_hours
      else
        rows << wrap_log_in_struct(log, true)
      end
    end

    sort_rows_by_date_and_duration(rows)
  end

  def sort_rows_by_date_and_duration(rows)
    rows.sort do |row1, row2|
      result = row1.date <=> row2.date
      result = row2.duration <=> row1.duration if 0 == result
      result
    end
  end

  def find_existing_row(log, rows)
    log_start = log.start_time

    result = rows.find do |row|
      row.date.year == log_start.year &&
        row.date.month == log_start.month &&
        row.date.day == log_start.day &&
        row.category == log.category.name &&
        row.log.strip.downcase == log.text.strip.downcase &&
        row.billable == log.billable
    end
    result
  end

  def wrap_log_in_struct(log, add_as_child)
    OpenStruct.new( :database_id => log.id,
                    :date => log.start_time,
                    :category => log.category.name,
                    :log => log.text,
                    :duration => log.duration_in_hours,
                    :duration_seconds => log.duration_in_seconds,
                    :billable => log.billable,
                    :children => add_as_child ? [wrap_log_in_struct(log, false)] : []
                    )
  end

  def build_category(categories, rows, category)
    sub_categories = find_sub_categories(categories, category.name).inject([]) {|list, c| list << build_category(categories, rows, c); list}
    children = rows.find_all {|row| row.category == category.name}

    sub_categories.reject! { |sub_category| sub_category.children.empty? and sub_category.sub_categories.empty? }

    OpenStruct.new( :name => category.name,
                    :sub_categories => sub_categories,
                    :children => children,
                    :duration => 0.0 +
                    sub_categories.inject(0.0){|sum, e| sum + e.duration} +
                    children.inject(0){|sum, e| sum + e.duration}
                    )
  end

  def find_sub_categories(categories, category_name)
    categories.find_all {|c| c.name =~ /#{category_name}:[^:]+$/}
  end
end
