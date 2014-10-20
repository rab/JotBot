# This file is used internally by the Database Manager to create and/or update
# the tables in the database.  The determination on weather or not to run
# any migrations is based on the one row in the version column inside the
# schema_info table.

require 'sequel_model'

# Consider using alas_method to munger column vlaues and passing them
# on to the orignal method
#module Sequel
#  class Model
#    alias_method :original_initialize, :initialize

#      def initialize(values = nil, from_db = false, &block)
#        if values
#          values.keys.map!{|v| v.to_s.downcase.intern }
#        end
#        original_initialize values, from_db, &block
#      end
#

#    # Create the column accessors
#    def self.def_column_accessor(*columns) # :nodoc:
#      include(@column_accessors_module = Module.new) unless @column_accessors_module
#      # Fix the UPCASE thing:
#      columns.map!{|c| c.to_s.downcase.intern }

#      columns.each do |column|
#        im = instance_methods.collect{|x| x.to_s}
#        meth = "#{column}="
#        @column_accessors_module.module_eval do
#          define_method(column){self[column]} unless im.include?(column.to_s)
#          unless im.include?(meth)
#            define_method(meth) do |*v|
#              len = v.length
#              raise(ArgumentError, "wrong number of arguments (#{len} for 1)") unless len == 1
#              self[column] = v.first
#            end
#          end
#        end
#      end
#    end
#  end

# end

LOGGER.info "Migrating database"
database = DatabaseManager.instance.db
unless database.table_exists? :schema_info
  LOGGER.info "Schema info does not exist, creating"
  database.create_table :schema_info do
    column :version, :integer
  end

  database[:schema_info] << {:version => 0}
end

schema_version = database[:schema_info].first  ? database[:schema_info].first[:version] : 0

if schema_version < 1
  database.create_table :timelogs do
    primary_key :id
    column :text, :varchar, :null => false
    column :start_time, :datetime, :null => false
    column :end_time, :datetime, :null => false
    column :duration_in_seconds, :integer, :null => false
    column :billable, :boolean, :null => false
    column :category_id, :integer, :null => false

    index :start_time
    index :end_time
  end

  database[:schema_info].update(:version => 1)
end

if schema_version < 2
  database.create_table :categories do
    primary_key :id
    column :name, :varchar, :null => false
    column :billable, :boolean, :default => false, :null => false
    column :active, :boolean, :default => true
  end

  database[:categories] << {:name => "Personal", :billable => false}
  database[:categories] << {:name => "Work", :billable => true}
  database[:schema_info].update(:version => 2)
end

if schema_version < 3
  database.create_table :timelog_details do
    primary_key :id
    column :text, :text, :null => false
    column :start_time, :datetime, :null => false
    column :end_time, :datetime, :null => false
    column :timelog_id, :integer, :null => false
  end

  database[:schema_info].update(:version => 3)
end

if schema_version < 4
  database.create_table :report_filters do
    primary_key :id
    column :filter_type, :varchar, :null => false
    column :parameter, :varchar
    column :report_id, :integer #, :null => false
  end

  class ReportFilter < Sequel::Model
    many_to_one :reports
  end

  # Create the filters

  yesterday_rf = ReportFilter.new(:filter_type => "date", :parameter => "yesterday")
  today_rf  =  ReportFilter.create(:filter_type => "date", :parameter => "today" )

  if  yesterday_rf.parameter == "today"
    raise "Failed to correctly create associated  filter for yesterday"
  end

  yesterday_rf.save # = ReportFilter.new(:filter_type => "date", :parameter => "yesterday")

  if  yesterday_rf.parameter == "today"
    raise "Failed to correctly create associated  filter for yesterday"
  end

  # Now do the reports
  database.create_table :reports do
    primary_key :id
    column :name, :varchar, :null => false
  end

  class Report < Sequel::Model
    one_to_many :report_filters
  end

  today = Report.create(:name => "Date is today")
  today.save
  today.add_report_filter( today_rf )
  today.save

  yesterday = Report.create(:name => "Date is yesterday")
  yesterday.save
  yesterday.add_report_filter(yesterday_rf)

  raise "Failed to correctly save assoicated   filter for yesterday" unless yesterday.report_filters.size > 0
  yesterday.save
  raise "Failed to correctly save assoicated   filter for yesterday" unless yesterday.report_filters.size  == 1
  raise "Failed to correctly save assoicated   filter for yesterday" if  yesterday.report_filters.first.parameter == "today"

  this_week = Report.create(:name => "Date is this week")
  this_week.save
  this_week.add_report_filter(ReportFilter.create(:filter_type => "date", :parameter => "this week") )
  this_week.save

  last_week = Report.create(:name => "Date is last week")
  last_week.save
  last_week.add_report_filter(ReportFilter.create(:filter_type => "date", :parameter => "last week"))
  last_week.save

  this_month = Report.create(:name => "Date is this month")
  this_month.save
  this_month.add_report_filter(ReportFilter.create(:filter_type => "date", :parameter => "this month"))
  this_month.save

  last_month = Report.create(:name => "Date is last month")
  last_month.save
  last_month.add_report_filter(ReportFilter.create(:filter_type => "date", :parameter => "last month"))
  last_month.save

  this_year = Report.create(:name => "Date is this year")
  this_year.save
  this_year.add_report_filter(ReportFilter.create(:filter_type => "date", :parameter => "this year"))
  this_year.save

  last_year = Report.create(:name => "Date is last year")
  last_year.save
  last_year.add_report_filter(ReportFilter.create(:filter_type => "date", :parameter => "last year"))
  last_year.save

  database[:schema_info].update(:version => 4)
end

# Add in a single details field, this replaces spearate log_detail rows for the 1.0 version.
if schema_version < 5
  database.alter_table :timelogs do
    add_column :details, :text, :null => false, :default => ''
  end

  database[:schema_info].update(:version => 5)
end
