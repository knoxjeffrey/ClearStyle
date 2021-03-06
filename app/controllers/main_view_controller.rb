class MainViewController < UIViewController
  
  extend IB
  include UIScrollViewDelegate, TableViewCellDelegate, TableViewDelegate 
  
  TODO_CELL_ID = "cell"
  
  attr_accessor :todo_list_manager
  
  outlet :table_view, UITableView
  
  def viewDidLoad
    super
    table_view.dataSource = self
    table_view.delegate = self
    # tells table_view to use CustomTableViewCell class when it needs a cell with reuse identifier TODO_CELL_ID
    table_view.registerClass(CustomTableViewCell.self, forCellReuseIdentifier: TODO_CELL_ID)
    @todo_list_manager = TodoListManager.new
    table_view.separatorStyle = UITableViewCellSeparatorStyleNone
    table_view.backgroundColor = UIColor.blackColor
    table_view.rowHeight = 50.0
  end
  
  #############################
  # Table view data source
  # contains numberOfSectionsInTableView, numberOfRowsInSection, cellForRowAtIndexPath
  #############################
  
  def tableView(table_view, numberOfRowsInSection: section)
    self.todo_list_manager.todo_items.count
  end

  def tableView(table_view, cellForRowAtIndexPath: indexPath)
    cell = table_view.dequeueReusableCellWithIdentifier(TODO_CELL_ID, forIndexPath: indexPath).tap do |cell|
      item = todo_list_manager.todo_items[indexPath.row]
      
      cell.selectionStyle = UITableViewCellSelectionStyleNone
      cell.textLabel.backgroundColor = UIColor.clearColor
      
      # allows custom_table_view_cell to pass message to this view controller
      # todo_item_deleted is called to delete a row
      cell.table_view_cell_delegate = self
      
      # pass the content of the cell to custom_table_view_cell
      cell.todo_item = item
    end
  end

  #############################
  # add, delete, edit methods
  #############################
  
  # delegate method for custom_table_view_cell
  def todo_item_deleted(todo_item) 
    index = todo_list_manager.todo_items.indexOfObject(todo_item)
    
    todo_list_manager.todo_items.delete_at(index)
    todo_list_manager.save
    
    visible_cells = table_view.visibleCells
    #cell_being_deleted = visible_cells[index]
    last_view = visible_cells[visible_cells.count - 1]
    start_animating = false

    # slides the deleted cell to the left first and then shifts up the table
    # stock animation for deleteRowsAtIndexPaths merges the two animations and doesn't look as good
    visible_cells.each_with_index do |cell, cell_index|
      if cell_index == index
        #toggle_cross_symobol_cell(cell_being_deleted)

        UIView.animateWithDuration(0.2, 
                delay: 0.0, 
                options: UIViewAnimationOptionCurveEaseOut,
                animations: proc { cell.frame = CGRectOffset(cell.frame, -cell.frame.size.width, 0) },
                completion: proc { |cell| break if cell_index == index }
        )
      elsif start_animating
        UIView.animateWithDuration(0.2, 
                delay: 0.2, 
                options: UIViewAnimationOptionCurveEaseIn,
                animations: proc { cell.frame = CGRectOffset(cell.frame, 0, -cell.frame.size.height) },
                completion: Proc.new do |cell| 
                              if cell_index == visible_cells.count - 1
                                table_view.reloadData
                                #toggle_cross_symobol_cell(cell_being_deleted)
                              end
                            end
        )
      end
      
      start_animating = true if cell.todo_item == todo_item 

    end
    
    # although I use my own animation to handle the cell being deleted to the left I had to include this to properly manage deleting info from the table and preventing flicker
    table_view.beginUpdates
    indexPathForRow = NSIndexPath.indexPathForRow(index, inSection: 0)
    table_view.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: UITableViewRowAnimationLeft)
    table_view.endUpdates
    
    
    # reload the cells after the delete animation has finished to keep the proper color gradient
    #self.performSelector("reload_table_view_after_delete", withObject: nil, afterDelay: 0.55)  
  end
  
  #def toggle_cross_symobol_cell(view)
  #  cell_subviews = view.subviews
  #  
  #  cell_subviews.each do |view|
  #    if view.isKindOfClass(UILabel) && view.text != "\u2713"
  #      view.text == "\u2717" ? view.text = "" : view.text = "\u2717"
  #    end
  #  end
  #end
  
  def todo_item_saved
    todo_list_manager.save
  end
  
  #def reload_table_view_after_delete
  #  table_view.reloadData
  #end
  
  def todo_item_added
    todo_item = todo_list_manager.create_todo_with_content("")
    todo_list_manager.todo_items.unshift(todo_item)
    #table_view.reloadData # empty cell will appear at top of table
    
    table_view.beginUpdates
    indexPathForRow = NSIndexPath.indexPathForRow(0, inSection: 0)
    table_view.insertRowsAtIndexPaths([indexPathForRow], withRowAnimation: UITableViewRowAnimationTop)
    table_view.endUpdates
    
    # enter edit mode
    visible_cells = table_view.visibleCells
    visible_cells.each do |cell|
      if cell.todo_item == todo_item
        edit_cell = cell
        edit_cell.render_label.becomeFirstResponder # user can now type
        break
      end
    end
    
  end
  
end