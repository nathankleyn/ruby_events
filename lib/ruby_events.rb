# The RubyEvents module contains the core logic used by the events firing class.
# All Object's are extended by default with an events accessor that is set to
# an instance of the RubyEvents::Events class. By calling the methods on this
# accessor, you can set up and listen to events or callbacks as fired by this
# class.
module RubyEvents
  # The Events class. Contains all the methods and functionality that drives
  # the actual processes of adding, listening, calling and receiving events.
  class Events
    # The current version of RubyEvents.
    def self.version
      '1.0.0'
    end
    
    # Initialize the events class by instantiating the class methods we'll be
    # using.
    def initialize(parent)
      @parent, @events = parent, {}
    end

    # Add a listener to the passed event type. You can pass a Proc, an array of
    # Proc's, or a block.
    def listen(event_type, procs = nil, &block)
      @events[event_type] = [] unless event_is_defined(event_type)
      procs_collected = []
      if procs.respond_to?(:each) && procs.respond_to?(:to_a)
        procs_collected += procs.to_a
      elsif procs
        procs_collected << procs
      end
      procs_collected << block if block
      @events[event_type] += procs_collected
    end

    # Fire all registered listeners to the passed event, passing them the
    # arguments as provided.
    def fire(event_type, *arguments)
      @events[event_type].each do |event|
        event.call(*arguments)
      end if event_is_defined(event_type)
    end
    
    # Set an event to fire when passed method is called. This is useful for
    # adding callbacks or events to built-in methods.
    def fire_on_method(method, event_type, &block)
      # We alias @parent to parent here, because class_eval can't see outside
      # this scope otherwise.
      parent, old_method = @parent, ('ruby_events_' + method.to_s + '_event_old').to_sym
      if parent && parent.respond_to?(method)
        parent.class.class_eval do
          # If the parent is already responding to the alias method, it means
          # the fire_on_method event was already triggered. Remove the other
          # event and continue if this happens.
          if parent.respond_to?(old_method, true)
            remove_method method
            alias_method method, old_method
            remove_method old_method
          end
        
          alias_method old_method, method
          private old_method
          
          # Make sure the self.send is at the end, or we won't return what we
          # are supposed to.
          define_method method do |*args|
            events.fire(event_type, *args)
            block.call(*args) if block # Calling the block we've been passed
            __send__(old_method, *args)
          end
        end
      else
        raise RuntimeError.new('The given object does not respond to method you are trying to intercept calls to.')
      end
    end

    # Remove a method from the listening queue.
    def remove(event_type, event)
      @events[event_type].delete_if {|stored_event| stored_event == event} if event_is_defined(event_type)
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
