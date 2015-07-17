class CustomTableViewCell < UITableViewCell
  
  Gesture = Struct.new(:original_center, :delete_on_drag_release, :complete_on_drag_release)
  
  LABEL_LEFT_MARGIN = 15.0
  UI_CUES_MARGIN = 30.0
  UI_CUES_WIDTH = 50.0
  
  attr_reader :todo_item
  attr_accessor :gesture, :table_view_cell_delegate
  
  def initWithStyle(style, reuseIdentifier: reuseIdentifier)
    super
    render_label.delegate = self
    render_label.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter
    self.addSubview(render_label)
    self.addSubview(tick_label)
    self.addSubview(cross_label)
    
    # remove the default blue highlight for selected cells
    self.selectionStyle = UITableViewCellSelectionStyleNone
    
    # make the Gesture instance variables available throughout this class to determine
    # the state of the gesture
    @gesture = Gesture.new(CGPoint, false, false)
    
    # new layer to create a color gradient for each cell. Light at top to dark at bottom
    self.layer.insertSublayer(gradient_layer, atIndex: 0)
    
    # add a layer that renders a green background when an item is complete
    self.layer.insertSublayer(item_complete_layer, atIndex: 0)
    
    addGestureRecognizer(recognizer)

  end
  
  # position each subview
  def layoutSubviews
    super
    
    #ensure the gradient layers occupies the full bounds
    gradient_layer.frame = self.bounds
    item_complete_layer.frame = self.bounds
    
    render_label.frame = CGRectMake(LABEL_LEFT_MARGIN, 0,
                                    self.bounds.size.width - LABEL_LEFT_MARGIN,self.bounds.size.height)  
    tick_label.frame = CGRectMake(-UI_CUES_WIDTH - UI_CUES_MARGIN,
                                  0, UI_CUES_WIDTH, self.bounds.size.height)
    cross_label.frame = CGRectMake(self.bounds.size.width + UI_CUES_MARGIN,
                                   0, UI_CUES_WIDTH, self.bounds.size.height)
  end
  
  def todo_item=(todo_item)
    @todo_item = todo_item
    
    #we must update all the visual state associated with the model item
    render_label.text = todo_item.content
    render_label.strikethrough = todo_item.completed
    item_complete_layer.hidden = !todo_item.completed
  end
  
  # create a label that renders the to-do item text
  def render_label
    @render_label ||= StrikeThroughText.alloc.initWithFrame(CGRectNull).tap do |render_label|
      render_label.textColor = UIColor.whiteColor
      render_label.font = UIFont.boldSystemFontOfSize(16)
      render_label.backgroundColor = UIColor.clearColor
    end
  end
  
  def tick_label
    @tick_label ||= self.create_cue_label.tap do |tick_label|
      tick_label.text = "\u2713"
      tick_label.textAlignment = NSTextAlignmentRight
    end
  end
  
  def cross_label
    @cross_label ||= self.create_cue_label.tap do |cross_label|
      cross_label.text = "\u2717"
      cross_label.textAlignment = NSTextAlignmentLeft
    end
  end
  
  # utility method for creating the contextual cues for tick and cross
  def create_cue_label 
    @create_cue_label = UILabel.alloc.initWithFrame(CGRectNull).tap do |label|
      label.textColor = UIColor.whiteColor
      label.font = UIFont.boldSystemFontOfSize(32.0)
      label.backgroundColor = UIColor.clearColor
    end
  end
  
  # add a layer that overlays the cell adding a subtle gradient effect
  def gradient_layer  
    @gradient_layer ||= CAGradientLayer.layer.tap do |gradient_layer|
      gradient_layer.colors = colors
      gradient_layer.locations = [0.0, 0.01, 0.95, 1.0]
    end
  end
  
  # add a layer that renders a green background when an item is complete
  def item_complete_layer
    @item_complete_layer ||= CALayer.layer.tap do |item_complete_layer|
      item_complete_layer.backgroundColor = UIColor.alloc.initWithRed(0.0, green: 0.6, blue: 0.0, alpha: 1.0).CGColor
      item_complete_layer.hidden = true
    end
  end
  
  # creates a 4 step gradient for gradient_layer 
  def colors
    color1 = UIColor.colorWithWhite(1.0, alpha: 0.2).CGColor
    color2 = UIColor.colorWithWhite(1.0, alpha: 0.1).CGColor
    color3 = UIColor.clearColor().CGColor
    color4 = UIColor.colorWithWhite(0.0, alpha: 0.1).CGColor
    
    [color1, color2, color3, color4]
  end
  
  # looks for dragging actions on screen and calls handle_pan
  def recognizer
    recognizer ||= UIPanGestureRecognizer.alloc.initWithTarget(self, action: "handle_pan:").tap do |recognizer|
      recognizer.delegate = self
    end
  end
  
  # handles the pan gesture during the begin, changed and ended states
  def handle_pan(recognizer)
    state_began(recognizer)
    state_changed(recognizer)
    state_ended(recognizer)
  end
  
  # if the gesture has just started, record the current centre location
  def state_began(recognizer)
    if recognizer.state == UIGestureRecognizerStateBegan
      gesture.original_center = self.center
    end
  end
  
  def state_changed(recognizer)
    if recognizer.state == UIGestureRecognizerStateChanged
      # translate the center
      translation = recognizer.translationInView(self)
      self.center = CGPointMake(gesture.original_center.x + translation.x, gesture.original_center.y)
      
      #has the item has been dragged far enough to initiate a delete or complete?
      gesture.delete_on_drag_release = self.frame.origin.x < -self.frame.size.width / 2
      gesture.complete_on_drag_release = self.frame.origin.x > self.frame.size.width / 2
      
      # fade the contextual cues
      cue_alpha = ((self.frame.origin.x) / (self.frame.size.width / 2)).abs
      tick_label.alpha = cue_alpha
      cross_label.alpha = cue_alpha
 
      # indicate when the items have been pulled far enough to invoke the given action
      
      # when pulled far enough the tick will be either green if the item is completed
      # or red if canceling a completed todo 
      if gesture.complete_on_drag_release
        todo_item.completed == true ? tick_label.textColor = UIColor.redColor : tick_label.textColor = UIColor.greenColor
      else
        tick_label.textColor = UIColor.whiteColor
      end

      cross_label.textColor = gesture.delete_on_drag_release ? UIColor.redColor : UIColor.whiteColor
    end
  end
  
  def state_ended(recognizer)
    if recognizer.state == UIGestureRecognizerStateEnded
      # the frame this cell would have had before being dragged
      original_frame = CGRectMake(0, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height)
      
      # notify the delegate that this item should be deleted when true
      if gesture.delete_on_drag_release
        table_view_cell_delegate.todo_item_deleted(todo_item)
      # render the strikethrough and show completed layer. Snap the cell back to starting point with animation
      elsif gesture.complete_on_drag_release
        if todo_item != nil
          todo_item.completed == true ? todo_item.completed = false : todo_item.completed = true
          table_view_cell_delegate.todo_item_saved
        end
         
        render_label.strikethrough == true ? render_label.strikethrough = false : render_label.strikethrough = true
        item_complete_layer.hidden == false ?  item_complete_layer.hidden = true :  item_complete_layer.hidden = false
        UIView.animateWithDuration(0.2, animations: proc { self.frame = original_frame })
      else 
        # if the item is not being deleted, snap back to the original location
        UIView.animateWithDuration(0.2, animations: proc { self.frame = original_frame })
      end
    end
  end
  
  # delgate method of a gesture recognizer - UIPanGestureRecognizer in this case
  # asks the delegate if a gesture recognizer should begin interpreting touches.
  def gestureRecognizerShouldBegin(gesture_recognizer)
    translation = gesture_recognizer.translationInView(self.superview)
    
    return true if translation.x.abs > translation.y.abs
    false
  end
  
  #############################
  # UITextFieldDelegate methods
  #############################
 
  def textFieldShouldReturn(text_field)
    # close the keyboard on Enter
    text_field.resignFirstResponder
    false
  end
 
  def textFieldShouldBeginEditing(text_field)
    # disable editing of completed to-do items
    return !todo_item.completed if todo_item != nil 
    return false
  end
  
  def textFieldDidBeginEditing(text_field) 
    table_view_cell_delegate.cellDidBeginEditing(self) if table_view_cell_delegate != nil
  end
  
  def textFieldDidEndEditing(text_field)
    todo_item.content = text_field.text if todo_item != nil
    table_view_cell_delegate.cellDidEndEditing(self) if table_view_cell_delegate != nil
  end
  
end