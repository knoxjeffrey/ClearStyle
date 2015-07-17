class TodoListManager
  attr_accessor :todo_items

  def initialize
    load
  end

  def create_todo_with_content(content)
    TodoItem.new(content)
  end
  
  # finds the absolute path for the documents folder and appends todo_items to it
  def storage_file
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0] + "/todo_items"
  end

  def load
    @todo_items = NSKeyedUnarchiver.unarchiveObjectWithFile(storage_file) || []
  end

  def save
    NSKeyedArchiver.archiveRootObject(todo_items, toFile: storage_file)
  end
end