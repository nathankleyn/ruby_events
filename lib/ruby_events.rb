module RubyEvents
  class Events
    def initialize(parent)
      @parent = parent
      @events = {}
    end

    def listen(event_type, &event)
      @events[event_type] = [] unless @events.has_key? event_type
      # TODO: Can we allow both block and an array of Proc's here?
#      events = [events] unless events.respond_to? :each
#      events.each do |event|
#        @events[event_type] << event
#      end
      @events[event_type] << event
    end

    def fire(event_type, *arguments)
      if @events.has_key?(event_type)
        @events[event_type].each do |event|
          event.call arguments
        end
      end
    end
    
    def fire_on_method(method, event_type, &block)
      old_method = (method.to_s + '_event_old').to_sym
      if @parent && @parent.respond_to?(method) && !@parent.respond_to?(old_method)
        @parent.class.class_eval do
          alias_method old_method, method
        end
        
        # FIXME: Without the internet, this is all I could remember; there is
        # definitely a better way to do this, so please fix it!
        #
        # FIXME: We need to find a way to call the block that's been passed
        # so they can define the arguments they want to pass to the event.
        #
        # We are using self.send instead of calling the method directory because
        # methods like << can not be resolved as a method properly once they've
        # had the _event_old suffix tacked on the end.
        #
        # Make sure the self.send is at the end, or we won't return what we
        # are supposed to.
        @parent.class.class_eval('def ' + method.to_s + '(*args); events.fire(:' + event_type.to_s + ', *args); self.send("' + old_method.to_s + '".to_sym, *args); end')
      else
        # TODO: Need to raise exception here.
      end
    end

    def remove(event_type, event)
      if @events.has_key?(event_type)
        @events[event_type].delete_if {|stored_event| stored_event == event}
      end
    end
  end
end

class Object
  def events
    @events || @events = RubyEvents::Events.new(self)
  end

  def events=(events)
    @events = events
  end
end
