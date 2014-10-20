class TimelogBaseController < ApplicationController
  def log_item_state_changed event
    return unless (event.state_change == java.awt.event.ItemEvent::SELECTED) && (view_transfer[:log_index] != -1)

    logs = Timelog.dataset.order(:start_time.desc).limit(10).all
    return if logs.nil? || logs.empty?
    unless  view_model.start_time.nil? || view_model.end_time.nil?
      update_model view_model, :message, :start_time, :end_time
    else
      update_model view_model, :message
    end
    model.selected_category = logs[view_transfer[:log_index]].category.name
    update_model(logs[view_transfer[:log_index]], :billable)
    update_view
  end

  def category_item_state_changed(event)
    return unless (event.state_change == java.awt.event.ItemEvent::SELECTED)
    category = Category.find(:name => view_model.selected_category)
    return if category.nil?
    transfer[:billable] = category.billable
    signal :update_billable
  end

  def continue_saving_record?
    if model.selected_is_new_category?
      signal :show_category_creation_prompt do |result|
        if 0 == result # Pressing of "Yes" button
          Category.create_category model.selected_category
          true
        else
          false
        end
      end
    else
      true
    end
  end
end
