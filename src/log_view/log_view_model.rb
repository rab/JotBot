require 'timelog'
require 'report'

class LogViewModel
  attr_accessor :logs
  attr_writer :filter_selection_model

  def initialize
    @logs = all_logs
  end

  def load_log_data
    # It isn't clear if any code is using this for its return value, but it does seem
    # that code is counting on @logs
    return(@logs = all_logs) if @filter_selection_model.current_report_is_empty?

    filter, joins = @filter_selection_model.current_report.build_filter

    if filter.empty?
      Timelog.dataset.all
    else
      if joins.empty?
        dataset = Timelog.filter(filter).order(:end_time.desc).all
      else
        dataset = Timelog.filter(filter).order(:end_time.desc)
        joins.each do |join|
          dataset = dataset.inner_join(join[0], join[1])
        end
        dataset
      end
    end

    @logs = dataset

  end

  private

  def all_logs
    Timelog.dataset.order(:end_time.desc).all
  end
end
