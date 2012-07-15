require 'category'
require 'timelog_base_model'
require 'debuggery'

class TimelogModel
  attr_accessor :message, :previous_messages, :details, :categories, :selected_category, :billable, :start_time, :end_time, :end_time_select

  include Neurogami::Debuggery

  def initialize
    self.extend TimelogBaseModel
    @details = ''
    @categories = {}

    messages = Timelog.dataset.limit(10).order(:end_time.desc).all

    if messages.size > 0
      @previous_messages = messages.map{|message| message.text}
      @message = @previous_messages.first
      self.selected_category = messages.first.category.name
    else
      @previous_messages = []
      @message = 'Worked on '
      @category = nil
      @billable = false
    end

    @start_time = nil
    @end_time = nil
    @end_time_select = nil
    @interval_queue ||= []
    LOGGER.info "Created TimelogModel!"
  end

  def start_time=(t)
    LOGGER.info " Cannot set start_time to nil, called  #{caller_method_name}" if t.nil?
    raise "Cannot set start_time to nil" if t.nil?

    @start_time = t
  end


  def end_time=(t)
    LOGGER.info " Cannot set end_time to nil, called  #{caller_method_name}" if t.nil?
    raise "Cannot set end_time to nil" if t.nil?
    @end_time = t
  end



  def start_time
    @start_time
  end


  def end_time
    @end_time
  end

  def interval_queue
    @interval_queue
  end

  def interval_queue=(iq)
    @interval_queue = iq
    unless @interval_queue.nil? || @interval_queue.empty?
      @start_time ||= @interval_queue.first.first
      @end_time   ||= @interval_queue.first.last
    end
  end


  def add_to_queue(start_time, end_time)
    @interval_queue << [start_time, end_time]
    @start_time = @interval_queue.first.first
    @end_time = @interval_queue.first.last
    # JGBDEBUG
    LOGGER.error "add_to_queue is setting nils on time fields" if @start_time.nil? || @end_time.nil?
    raise "add_to_queue is setting nils on time fields" if @start_time.nil? || @end_time.nil?
  end

  def save
    log = Timelog.new :text => @message.strip,
      :start_time => @start_time,
      :end_time => @end_time,
      :duration_in_seconds => duration_in_seconds,
      :billable => @billable,
      :category => Category.find(:name => @selected_category),
      :details => @details

    log = update_existing_log_or_save log

    #    unless @details.nil? or @details.strip.empty?
    #      LOGGER.info "Saving detail record"
    #      TimelogDetail.create :text => @details,
    #                           :start_time => @start_time,
    #                           :end_time => @end_time,
    #                           :timelog => log
    #    end

    update_next_log_time log.id
    clear_all_entries_up_to_current_entry
  end

  private
  def clear_all_entries_up_to_current_entry 
    if 1 == @interval_queue.size
      @interval_queue.clear 
    else
      @interval_queue.reject! do |interval|
        # We want to remove all intervals that fall inside the selected log interval
        # So drop anything that has a start time before the selected end time
        # [s e][s e][s e][s e][s e][s e]
        # [s           e]
        interval.first < @end_time
      end
    end
  end
end
