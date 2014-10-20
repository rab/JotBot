require 'timelog'

module TimelogBaseModel
  def duration_in_seconds(start_time = @start_time, end_time = @end_time)
    end_time - start_time
  end

  def selected_is_new_category?
    @categories.each do |name, category|
      return false if category.name == @selected_category
    end
    return true
  end

  def load_catagories
    self.categories = Category.dataset.where(:active => true).order(:name).all
  end

  def categories=(category_list)
    @categories.clear
    category_list.each do |category|
      @categories[category.name] = category
    end
  end

  def selected_category=(category)
    unless category.nil? or (category == @selected_category)
      @selected_category = category
      if @categories[category].nil?
        @billable = false
      else
        @billable = @categories[category].billable
      end
    end
  end

  # Finds existing log that is contiguous with the new log and updated it, if no existing log can be found the log passed in is saved.
  # Returns which ever log was saved.
  def update_existing_log_or_save(log)
    existing_log = Timelog.find(:text => log.text, :category_id => log.category.id, :end_time => log.start_time, :billable => log.billable)
    if existing_log.nil?
      LOGGER.info 'Saving new log'
      log.details = log.details.chomp
      log.save!
      log
    else
      LOGGER.info 'Found existing log, modifying end time and duration'
      if log.details.strip.empty?
        details_text = existing_log.details.strip
      else
        if existing_log.details.split("\n").find{|line| line =~ /^==.*==$/}
          details_text = "#{existing_log.details.strip}\n==#{log.start_time.strftime("%I:%M %p")} - #{log.end_time.strftime("%I:%M %p")}============\n#{log.details.strip}"
        else
          details_text = "==#{existing_log.start_time.strftime("%I:%M %p")} - #{existing_log.end_time.strftime("%I:%M %p")}============\n#{existing_log.details.strip}\n==#{log.start_time.strftime("%I:%M %p")} - #{log.end_time.strftime("%I:%M %p")}============\n#{log.details.strip}"
        end
      end
      existing_log.end_time = log.end_time
      existing_log.duration_in_seconds = duration_in_seconds(existing_log.start_time, existing_log.end_time)
      existing_log.details = details_text
      existing_log.save!
      log.delete! unless log.new_record?
      existing_log
    end
  end

  def update_next_log_time log_id
    last_log = nil
    begin
      last_log = Timelog.find(:id => log_id)
    rescue Exception => e
      LOGGER.warn "Error finding timelog with id #{log_id}"
      raise
    end
    if time_ranges_overlap?((last_log.start_time..last_log.end_time), (Main.instance.last_log_time..Main.instance.next_log_time))
      Main.instance.last_log_time = last_log.end_time
    end
  end

  def time_ranges_overlap?(range1, range2)
    (range1.first <= range2.first && range1.last  >= range2.last) ||
      (range2.first <= range1.first && range2.last  >= range1.last) ||
      (range1.first >= range2.first && range1.first <= range2.last) ||
      (range1.last  >= range2.first && range1.last  <= range2.last)
  end
end
