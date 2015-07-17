#############################
# Table view delegate methods
# contains willDisplayCell and helper method color_for_index
#############################

module TableViewDelegate
 
  def tableView(table_view, willDisplayCell: cell, forRowAtIndexPath: index_path)
    cell.backgroundColor = color_for_index(index_path.row)
  end
  
  # creates the color gradient from top to bottom cell
  def color_for_index(index_value)
    item_count = todo_list_manager.todo_items.count - 1
    val = index_value.to_f / item_count.to_f * 0.6
    
    UIColor.colorWithRed(1.0, green: val, blue: 0.0, alpha: 1.0)
  end
  
end