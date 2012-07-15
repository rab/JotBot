require 'timelog_base_model'
require 'timelog_detail'

class TimelogEditModel
  attr_accessor :start_time, :end_time, :categories, :message, :previous_messages, :details, :selected_category, :billable, :new_log, :id, :current_detail_index

  def initialize
    self.extend TimelogBaseModel
    @details = ''
    @current_detail_index = nil
    @categories = {}

    messages = Timelog.dataset.limit(10).order(:start_time.desc).all
    
    if messages.size > 0
      @previous_messages = messages.map{|message| message.text}
      @message = @previous_messages.first
      self.selected_category = messages.first.category.name
    else
      @previous_messages = []
      @message = 'Worked on '
      self.selected_category = nil
      @billable = false
    end

    @start_time = nil
    @end_time = nil
  end

  def save
    if @new_log
      log = Timelog.new
    else
      log = Timelog[@id]
    end

    log.text = @message.strip
    log.start_time = @start_time
    log.end_time = @end_time
    log.duration_in_seconds = duration_in_seconds
    log.billable = @billable
    log.category = Category.find(:name => @selected_category)
    log.details = @details

    log = update_existing_log_or_save log
    update_next_log_time log.id
  end

  def populate_from_defaults
    default_values = TimelogController.instance.current_log_details

    default_category = default_values[:category]
    default_billable = default_values[:billable]
    details_text = default_values[:details]
    default_message = default_values[:message]

    @message = default_message unless default_message.nil?
    @selected_category = default_category unless default_category.nil?
    @billable = default_billable unless default_billable.nil?
    @current_detail_index = nil
    @new_log = true
    @start_time = Main.instance.last_log_time
    @end_time = Time.now.round_seconds_down
  end

  def populate_from_log_id(id)
    log = Timelog[id]
    @id = id
    @start_time = log.start_time
    @end_time = log.end_time
    @message = log.text
    @previous_messages = []
    @details = log.details
    @selected_category = log.category.name
    @billable = log.billable?
    @new_log = false
  end
end
