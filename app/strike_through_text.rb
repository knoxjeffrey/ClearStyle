class StrikeThroughText < UITextField
  STRIKEOUT_THICKNESS = 2.0
  
  attr_reader :strikethrough
 
  def initWithFrame(frame)
    super.tap do
      self.layer.addSublayer(strikethrough_layer)
    end
  end
      
  def layoutSubviews
    super
    resize_strike_through if text
  end
  
  #resizes the strikethrough layer to match the current label text
  def resize_strike_through
    text_size = text.sizeWithAttributes({ NSFontAttributeName => font })
    strikethrough_layer.frame = CGRectMake(0, self.bounds.size.height/2,
                                             text_size.width, STRIKEOUT_THICKNESS)
  end
 
  # property setter
  def strikethrough=(strikethrough)
    @strikethrough = strikethrough
    strikethrough_layer.hidden = !strikethrough
    resize_strike_through if strikethrough
  end
  
  def strikethrough_layer
    @strikethrough_layer ||= CALayer.layer.tap do |strikethrough_layer|
      strikethrough_layer.backgroundColor = UIColor.whiteColor.CGColor
      strikethrough_layer.hidden = true
    end
  end
  
end