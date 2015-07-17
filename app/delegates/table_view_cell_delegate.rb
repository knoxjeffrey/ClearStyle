#############################
# TableViewCellDelegate methods
# contains toDoItemDeleted, cellDidBeginEditing, cellDidEndEditing
#############################

module TableViewCellDelegate  
  
  # Using a transform below has the big advantage that it is easy to move a cell back to its original location: you simply “zero” the translation (i.e., apply the identity), instead of having to store the original frame for each and every cell that is moved
  
  # indicates that the edit process has begun for the given cell
  def cellDidBeginEditing(editing_cell) 
    editing_offset = table_view.contentOffset.y - editing_cell.frame.origin.y
    visible_cells = table_view.visibleCells
    
    visible_cells.each do |cell|
      UIView.animateWithDuration(0.3,
        animations: proc {
          cell.transform = CGAffineTransformMakeTranslation(0, editing_offset)
          cell.alpha = 0.3 if cell != editing_cell
        }
      )
    end
    
  end
  
  # indicates that the edit process has committed for the given cell
  def cellDidEndEditing(editing_cell)
    visible_cells = table_view.visibleCells
    
    visible_cells.each do |cell|
      UIView.animateWithDuration(0.3,
        animations: proc {
          cell.transform = CGAffineTransformIdentity
          cell.alpha = 1.0 if cell != editing_cell
        }
      )
    end

    todo_item_deleted(editing_cell.todo_item) if editing_cell.todo_item.content == ""
    todo_item_saved
  end
  
end