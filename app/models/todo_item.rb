class TodoItem
  
  # ensures TodoItem conforms to NSCoding
  include Serializable
  
  attr_accessor :content, :completed
  
  def initialize(content, completed = false)
    @content = content
    @completed = completed
  end

end