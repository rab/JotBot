require 'category'
#require 'timelog_detail'
require 'time'

class Timelog < Sequel::Model

  belongs_to :category
  #  has_many :timelog_details
  validates_presence_of :text
  validates_presence_of :start_time
  validates_presence_of :end_time
  validates_presence_of :duration_in_seconds

  alias_method :original_start_time, :start_time
  alias_method :original_end_time, :end_time
  alias_method :original_details, :details

  alias_method  :'new_record?', :'new?'

  def duration_in_minutes
    sprintf("%0.02f", duration_in_seconds / 60.0).to_f
  end

  def duration_in_hours
    sprintf("%0.02f", duration_in_seconds / (60.0 * 60.0)).to_f
  end

  def start_time
    # We want to coerce this to a Ruby time
    sql_timestamp_to_time self.original_start_time
  end

  def end_time
    # We want to coerce this to a Ruby time
    sql_timestamp_to_time self.original_end_time
  end

  def billable?
    billable
  end

  def details #JDBC/Sequel is returning a Java::JavaIo::BufferedReader, we need a string
    return original_details if original_details.kind_of?(String)
    string = ""
    return string if original_details.nil?

    original_details.mark(3000)

    while original_details.ready
      string += original_details.read_line + "\n"
    end
    original_details.reset
    string
  end

  private

  def sql_timestamp_to_time(ts)
    return ts if ts.is_a?(Time) # We need to see why we might ever pass a Ruby Time object, and avoid using this method.
    milliseconds = ts.time #+ (time.nanos / 1000000)
    Time.at(milliseconds/1000)
  end

end
