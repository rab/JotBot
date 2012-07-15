module Neurogami
  module TimeHelpers


    def hours_to_hours_minutes_seconds hours
      duration_in_seconds  = (hours * 60.0 * 60.0).to_f
      seconds_as_hhmmss duration_in_seconds
    end

    def seconds_to_hours_minutes_seconds seconds
      duration_in_seconds  = seconds.to_f
      seconds_as_hhmmss duration_in_seconds
    end

    def seconds_as_hhmmss seconds
      Time.at(seconds).gmtime.strftime('%R:%S')
    end

    def seconds_to_hours_decimal duration_in_seconds
      sprintf("%0.02f", duration_in_seconds / (60.0 * 60.0)).to_f
    end

  end
end
