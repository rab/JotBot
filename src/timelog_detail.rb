require 'timelog'

class TimelogDetail < Sequel::Model
  belongs_to :timelog

  alias_method  :original_start_time, :start_time
  alias_method  :original_end_time, :end_time

  def new_record?
    new?
  end

  def start_time
    # We want to coerce this to a Ruby time
    sql_timestamp_to_time self.original_start_time
  end

  def end_time
    # We want to coerce this to a Ruby time
    sql_timestamp_to_time self.original_end_time
  end

  def text #JDBC/Sequel is returning a Java::JavaIo::BufferedReader, we need a string
    return "" if @text.nil?

    string = ""
    while @text.ready
      string += text.read_line
    end
    string
  end

  private

  def sql_timestamp_to_time(ts)
    return ts if ts.is_a?(Time)
    milliseconds = ts.time
    Time.at(milliseconds/1000)
  end
end
