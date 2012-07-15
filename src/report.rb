class Report < Sequel::Model
	has_many :report_filters

	DATE = "date"
	CATEGORY = "category"
	BILLABLE = "billable"

	TODAY = "today"
	YESTERDAY = "yesterday"
	THIS_WEEK = "this week"
	LAST_WEEK = "last week"
	THIS_MONTH = "this month"
	LAST_MONTH = "last month"
	THIS_YEAR = "this year"
	LAST_YEAR = "last year"
	IS = 'is'
	IS_NOT = 'is not'
	BEFORE = 'before'
	AFTER = 'after'
	CONTAINS = 'contains'
	DOES_NOT_CONTAIN = 'does not contain'


	# Need to change this to create H2/Sequel filter values 
	def build_filter
		conditions = []
		joins = []

		report_filters.each do |filter|
			case filter.filter_type
			when DATE
				case filter.parameter
				when TODAY
					conditions << add_today_filter
				when YESTERDAY
					conditions << add_yesterday_filter
				when THIS_WEEK
					conditions << add_this_week_filter
				when LAST_WEEK
					conditions << add_last_week_filter
				when THIS_MONTH
					conditions << add_this_month_filter
				when LAST_MONTH
					conditions << add_last_month_filter
				when THIS_YEAR
					conditions << add_this_year_filter
				when LAST_YEAR
					conditions << add_last_year_filter
				when /^#{IS_NOT}/
					match = /#{IS_NOT} (\d+)\/(\d+)\/(\d+)/.match(filter.parameter)
					conditions << ["start_time != ?", Date.new(match[1].to_i, match[2].to_i, match[3].to_i).h2_format] 
                                when /^#{IS}/
					match = /#{IS} (\d+)\/(\d+)\/(\d+)/.match(filter.parameter)
					conditions << ["start_time = ?",  Date.new(match[1].to_i, match[2].to_i, match[3].to_i).h2_format]
				when /^#{BEFORE}/
					match = /#{BEFORE} (\d+)\/(\d+)\/(\d+)/.match(filter.parameter)
					conditions << ["start_time < ?", Date.new(match[1].to_i, match[2].to_i, match[3].to_i).h2_format] 
				when /^#{AFTER}/
					match = /#{AFTER} (\d+)\/(\d+)\/(\d+)/.match(filter.parameter)
					conditions << ["start_time > ?", Date.new(match[1].to_i, match[2].to_i, match[3].to_i).h2_format]  
				end
			when CATEGORY
				joins << [:categories, {:id => :category_id}]

				case filter.parameter
				when /^#{IS_NOT}/
					conditions << ["categories.name != ?", filter.parameter[IS_NOT.length..-1].strip ]
				when /^#{IS}/
					conditions << ["categories.name = ?", filter.parameter[IS.length..-1].strip ]
				when /^#{CONTAINS}/
					conditions << ["categories.name LIKE ?", "%#{filter.parameter[CONTAINS.length..-1].strip}%" ]
				when /^#{DOES_NOT_CONTAIN}/
					conditions << ["categories.name NOT LIKE ?", "%#{filter.parameter[DOES_NOT_CONTAIN.length..-1].strip}%" ]
				end
			when BILLABLE
				conditions << ["timelogs.billable = ?", ("yes" == filter.parameter ? true : false) ]
			end
		end

    conditions = merge_filter_conditions(conditions)
		[conditions, joins]
	end

private

	def merge_filter_conditions(conditions)
		conditions_string = conditions.map{|filter| filter[0]}.join(" AND ")
		conditions_values = conditions.map{|filter| filter[1..-1] }.flatten
		[conditions_string , conditions_values].flatten
	end


	def add_date_range_filter(start_date, end_date)
		start_date = start_date.h2_format
		end_date = (end_date + 1).h2_format
		["start_time between ? and ? ", start_date,  end_date ]
	end

	def add_today_filter
		add_date_range_filter(Date.today, Date.today)
	end

	def add_yesterday_filter
		add_date_range_filter(Date.today-1, Date.today-1)
	end

	def add_this_week_filter
		date = Date.today
		start_date = date - date.wday
		end_date = date + (6 - date.wday)
		add_date_range_filter(start_date, end_date)
	end

	def add_last_week_filter
		date = Date.today
		end_date = date - date.wday
		start_date = end_date - 7
		add_date_range_filter(start_date, end_date)
	end

	def add_this_month_filter
		date = Date.today
		end_year = (12 == date.month) ? date.year + 1 : date.year
		end_month = (12 == date.month) ? 1 : date.month + 1
		add_date_range_filter(Date.new(date.year, date.month, 1), Date.new(end_year, end_month, 1))
	end

	def add_last_month_filter
		date = Date.today
		begin_year = (0 == (date.month - 1)) ? date.year - 1 : date.year
		begin_month = (0 == (date.month - 1)) ? 12 : date.month - 1
		add_date_range_filter(Date.new(begin_year, begin_month, 1), Date.new(date.year, date.month, 1))
	end

	def add_this_year_filter
		date = Date.today
		add_date_range_filter(Date.new(date.year, 1, 1), Date.new(date.year, 12, 31))
	end

	def add_last_year_filter
		date = Date.today
		add_date_range_filter(Date.new(date.year - 1, 1, 1), Date.new(date.year - 1, 12, 31))
	end

end
