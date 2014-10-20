require 'time'

module H2DateFormat
  def h2_format
    self.strftime("%Y-%m-%d %H:%M:%S")
  end
end

class Date
  include H2DateFormat
end

class DateTime
  include H2DateFormat
end
