class PdfEmitter
  def emit_from_report_data(data, path)
    require 'prawn'
    require 'prawn/layout'
    array = to_array data
    Prawn::Document.generate path do |pdf|
      pdf.table array,
                :position           => :center,
                :headers            => ["Category", "Log", "Time", "Duration", "Billable?"],
                :row_colors         => ["ffffff","ffff00"],
                :vertical_padding   => 5,
                :horizontal_padding => 3
    end
  end
  
  def to_array(report_data, array=[])
    if report_data.respond_to? :each
      report_data.each do |category|
        to_array(category, array)
      end
    else
      report_data.sub_categories = [] if report_data.sub_categories.nil?
      (report_data.children + report_data.sub_categories).each do |log|
        if log.children.empty?
          array << [log.category.to_s, log.log.to_s, log.date.to_s, log.duration.to_s, log.billable ? 'Yes' : 'No']
        else
          to_array(log, array)
        end
      end
    end
    array
  end
end