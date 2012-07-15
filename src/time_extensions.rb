class Time
  def round_seconds_down
    self.class.local(self.year, self.month, self.day, self.hour, self.min, 0)
  end
end