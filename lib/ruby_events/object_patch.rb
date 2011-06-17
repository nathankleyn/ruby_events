# Extending the Object class with the events accessor.
class Object
  attr_writer :events
  
  # Attribute reader for the events accessor. Returns a new instance of the
  # events class if not defined, or the already defined class otherwise.
  def events
    @events ||= RubyEvents::Events.new(self)
  end
end
