class ReportEditorRowModel
  # Date format for filter is year/month/date (all 1 based, Jan = 1, Feb = 2)

  attr_accessor :type, :selected_parameter, :text_parameter

  DEFINED_DATE_TYPES = ["today", "yesterday", "this week", "last week", "this month", "last month", "this year", "last year"]
  #  ADDITIONAL_SELECTION_DATE_TYPES = ['is', 'is not', 'after', 'before', 'within', 'not within']
  ADDITIONAL_SELECTION_DATE_TYPES = ['is', 'is not', 'after', 'before'] #TODO: enable within/not within in report filter generation
  CATEGORY_SELECTION_TYPES = ['is', 'is not', 'contains', 'does not contain']
  BILLABLE_SELECTION_TYPES = ['yes', 'no']

  def initialize
    @type = "date"
    @selected_parameter = "today"
  end

  def from_filter(filter)
    @type = filter.filter_type
    case @type
    when "date"
      if DEFINED_DATE_TYPES.member? filter.parameter
        @selected_parameter = filter.parameter
      else
        ADDITIONAL_SELECTION_DATE_TYPES.each do |type|
          if filter.parameter.index(type)
            @selected_parameter = type
            @text_parameter = filter.parameter.sub(type, "").strip
          end
        end
      end
    when "category"
      CATEGORY_SELECTION_TYPES.each do |type|
        if filter.parameter.index(type)
          @selected_parameter = type
          @text_parameter = filter.parameter[type.length..-1].strip
          break
        end
      end

    when "billable"
      @selected_parameter = true == filter.parameter ? "yes" : "no"
    end
  end

  def to_filter
    filter = ReportFilter.new
    filter.filter_type = @type.downcase
    filter.parameter = "#{@selected_parameter} #{@text_parameter}".strip
    filter
  end
end
