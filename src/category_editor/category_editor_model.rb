
require 'category'

class CategoryEditorModel
  attr_accessor :selected_category_name, :selected_category_billable_status , 
                :selected_category_active_status , :selected_category_primary_id

  def CategoryEditorModel.create_intermediates(category_segments, attributes )
    until category_segments.empty?
      name = category_segments.join(':')
      c = Category.find(:name =>  name )
      if c.nil?
        attributes[:name]  = name
        Category.create(attributes)
      end
      category_segments.pop
    end
  end


  def update(category_id, attributes)
    Category.raise_on_save_failure = true    
    category = Category.find(:id => category_id )
    begin
      category.update(attributes) 
    rescue Exception => e
      warn "Error updating attributes on #{category.name}, #{attributes.inspect}: #{e.inspect}"
      warn category.inspect
      raise e 
    end

    Category.raise_on_save_failure = false    

    if attributes[:name] =~ /:/
      segments = attributes[:name].split(':')
      segments.pop
      attributes.delete(:name)
      self.class.create_intermediates(segments, attributes)
    end
  end

  def add(attributes)
    begin
      category = Category.create(attributes)
    rescue Exception => e
      warn "Error creating category #{category.inspect}: #{e}"
      raise e
    end

    if attributes[:name ] =~ /:/
      segments = attributes[:name].split(':')
      segments.pop
      attributes.delete(:name)
      self.class.create_intermediates(segments, attributes)
    end

  end

  def initialize
    @categories = {}
    reload_category_data
    set_attributes
  end

  def selected_category_name=(s)
    unless s.to_s.strip.empty?
      @selected_category_name = s
      #update_dependant_attributes
    end
  end

  def set_attributes
    @selected_category_name = category_names.first
    update_dependant_attributes
  end

  def update_dependant_attributes
    @selected_category_billable_status = @categories[@selected_category_name] ? @categories[@selected_category_name].billable : true
    @selected_category_active_status = @categories[@selected_category_name ] ? @categories[@selected_category_name ].active : true
    pid = @categories[@selected_category_name ] ? @categories[@selected_category_name ].id : 0
    @selected_category_primary_id = pid 
  end


  def selected_category_active_status 
    @selected_category_active_status 
  end

  def selected_category_active_status=(status)
    # Do we need to update the cache?
    # This breaksif we have edited the name
    # @categories[@selected_category_name].active = status
    @selected_category_active_status  = status
  end

  def selected_category_primary_id 
    @selected_category_primary_id 
  end

  def selected_category_name
    @selected_category_name
  end

  def category_names
    @categories.keys.sort
  end

  def reload_category_data
    @categories = {}
    Category.dataset.order( :name ).each {|c| @categories[c.name] = c }
    set_attributes
  end



  #def selected_category_billable_status 
  #  if c = Category.find(:all, :condition => "name = #{@selected_category_name}")
  #    c.billable_status
  #  else
  #    true
  #  end
  #end

  #def selected_category_billable_status=(billable_status) 
  #     if c = Category.find(:all, :condition => "name = #{@selected_category_name}")
  #    c.update_attributes :billable_status =>  billable_status
  #  else
  #    true
  #  end
  #  # We're assuming this is a new item if we so not have it in our categories set ...
  #  @categories[@selected_category_name] ||= "true||true"
  #  selected_category_active_status  =   eval( @categories[@selected_category_name].split('||').last )
  #  @categories[@selected_category_name] = "#{billable_status }||#{selected_category_active_status}"
  #end


  #def selected_category_active_status=(active_status)
  #  selected_category_billable_status = eval(@categories[@selected_category_name].split('||').first)
  #  selected_category_active_status  = active_status  
  #  @categories[@selected_category_name] = "#{selected_category_active_status}||#{selected_category_active_status}"
  #end


  #def selected_category_active_status
  #  return true unless @selected_category_name || @categories[@selected_category_name].to_s.strip.empty?
  #  eval(@categories[@selected_category_name].split('||').last)
  #end
end

