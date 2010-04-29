# The RubyEvents module contains the core logic used by the events firing class.
# All Object's are extended by default with an events accessor that is set to
# an instance of the RubyEvents::Events class. By calling the methods on this
# accessor, you can set up and listen to events or callbacks as fired by this
# class.
module RubyEvents
  # The Events class. Contains all the methods and functionality that drives
  # the actual processes of adding, listening, calling and receiving events.
  class Events
    # Initialize the events class by instantiating the class methods we'll be
    # using.
    def initialize(parent)
      @parent, @events = parent, {}
    end

    # Add a listener to the passed event type.
    def listen(event_type, &event)
      @events[event_type] = [] unless event_is_defined
      # TODO: Can we allow both block and an array of Proc's here?
      @events[event_type] << event
    end

    # Fire all registered listeners to the passed event, passing them the
    # arguments as provided.
    def fire(event_type, *arguments)
      @events[event_type].each do |event|
        event.call arguments
      end if event_is_defined
    end
    
    # Set an event to fire when passed method is called. This is useful for
    # adding callbacks or events to built-in methods.
    def fire_on_method(method, event_type, &block)
      method_s, old_method_s = method.to_s, old_method.to_s
      old_method = (method_s + '_event_old').to_sym
      if @parent && @parent.respond_to?(method) && !@parent.respond_to?(old_method)
        @parent = @parent.class
        @parent.class_eval do
          alias_method old_method, method
        end
        # FIXME: We need to find a way to call the block that's been passed
        # so they can define the arguments they want to pass to the event.
        #
        # We are using self.send instead of calling the method directory because
        # methods like << can not be resolved as a method properly once they've
        # had the _event_old suffix tacked on the end.
        #
        # Make sure the self.send is at the end, or we won't return what we
        # are supposed to.
        @parent.class_eval('def ' + method_s + '(*args); events.fire(:' + event_type.to_s + ', *args); self.send("' + old_method_s + '".to_sym, *args); end')
      else
        # TODO: Need to raise exception here.
      end
    end

    # Remove a method from the listening queue.
    def remove(event_type, event)
      @events[event_type].delete_if {|stored_event| stored_event == event} if event_is_defined
    end
    
    private
    # Checks if an event of event_type is defined in the collection of events.
    def event_is_defined(event_type)
      @events.has_key?(event_type)
    end
  end
end

# Extending the Object class with the events accessor.
class Object
  attr_writer :events
  
  # Attribute reader for the events accessor. Returns a new instance of the
  # events class if not defined, or the already defined class otherwise.
  def events
    @events || @events = RubyEvents::Events.new(self)
  end
end
