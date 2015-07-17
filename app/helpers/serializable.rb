# Makes any NSObject conform to the NSCoding protocol
# Authors:
# @rod_wilhelmy
# @cicloid
 
module Serializable
  
  # the methods method returns all available methods including any setters which are reurned as example_accessor:= The getters will just be example_accessor
  # grep looks for a pattern of any character followed by := and returns matching results in an array
  def attr_accessor_setters
    methods.grep(/\w=:$/)
  end
 
  def initWithCoder(decoder)
    attr_accessor_setters.each do |method|
      key = method.to_s.sub('=:', '') # for example method example_setter:= title will become "example_setter"
      
      # instance of class (self) will invoke the given setter method (eg example_setter:=) and pass the argument coder.decodeObjectForKey("example_setter")
      # eg  def example_setter=(coder.decodeObjectForKey("example_setter"))
      #       example_setter = coder.decodeObjectForKey("example_setter")
      #     end
      # this returns example_setter = coder.decodeObjectForKey("example_setter") which is the format needed for initWithCoder()  
      self.send(method, decoder.decodeObjectForKey(key))
    end
    self
  end
 
  def encodeWithCoder(encoder)
    attr_accessor_setters.each do |method|
      key = method.to_s.sub('=:', '')
      encoder.encodeObject(self.send(key), forKey:key)
    end
  end
 
end