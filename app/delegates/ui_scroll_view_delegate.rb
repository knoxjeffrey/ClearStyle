#############################
# UIScrollViewDelegate methods
# contains scrollViewDidScroll, and other methods, to keep track of dragging the scrollView
#############################

module UIScrollViewDelegate
  
  PullDown = Struct.new(:placeholder_cell, :pull_down_in_progress)
  
  TODO_CELL_ID = "cell"
  
  def pulldown
    @pulldown ||= PullDown.new(table_view_reference.dequeueReusableCellWithIdentifier(TODO_CELL_ID) , false)
  end
  
  # this behavior starts when a user pulls down
  def scrollViewWillBeginDragging(scroll_view)
    pulldown.placeholder_cell.backgroundColor = UIColor.redColor
    pulldown.pull_down_in_progress = scroll_view.contentOffset.y <= 0.0
    
    # add the placeholder
    table_view_reference.insertSubview(pulldown.placeholder_cell, atIndex: 0)  if pulldown.pull_down_in_progress 
  end
  
  def scrollViewDidScroll(scroll_view)
    scroll_view_content_offset_Y = scroll_view.contentOffset.y

    if pulldown.pull_down_in_progress && scroll_view.contentOffset.y <= 0.0 
      # maintain the location of the placeholder
      pulldown.placeholder_cell.frame = CGRectMake(0, -table_view_reference.rowHeight,
          table_view_reference.frame.size.width, table_view_reference.rowHeight)
      pulldown.placeholder_cell.render_label.text = -scroll_view_content_offset_Y > table_view_reference.rowHeight ?
          "Release to add item" : "Pull to add item"
      pulldown.placeholder_cell.alpha = [1.0, -scroll_view_content_offset_Y / table_view_reference.rowHeight].min
    else 
      pulldown.pull_down_in_progress = false
    end
  end
  
  def scrollViewDidEndDragging(scroll_view, willDecelerate: decelerate)
    # check whether the user pulled down far enough
    if pulldown.pull_down_in_progress && -scroll_view.contentOffset.y > table_view_reference.rowHeight
      todo_item_added
    end
    
    pulldown.pull_down_in_progress = false
    pulldown.placeholder_cell.removeFromSuperview
  end
  
  def table_view_reference
    table_view
  end
  
end