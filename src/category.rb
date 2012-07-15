require 'timelog'
require 'sequel'

class Category < Sequel::Model
  has_many :timelogs

  validates_presence_of :name
  validates_uniqueness_of :name

  def self.create_category(category_entry, billable=false)
    billable_status = billable
    name_sections = category_entry.split(":")

    Category.find_or_create_category(name_sections[0], billable_status)

    name_sections.inject do |prev_categories, current_category|
      new_category = prev_categories + ":" + current_category
      Category.find_or_create_category(new_category, billable_status)
      new_category
    end
  end

  def simple_inspect
    "[category:  id : #{id}; name : #{name}; billable : #{billable}; :active : #{active} ]"
  end

  private

  def self.find_or_create_category(category_name, billable_status)
    unless(category = Category.find( :name => category_name))
      Category.create(:name => category_name, :billable => billable_status)
    else
      category
    end
  end
end
