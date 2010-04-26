module RubyEvents
  class Events
    def initialize
      @events = {}
    end

    def listen(event_type, events)
      @events[event_type] = [] unless @events.has_key? event_type
      events = [events] unless events.respond_to? :each
      events.each do |event|
        @events[event_type] << event
      end
    end

    def fire(event_type, *arguments)
      if @events.has_key?(event_type)
        @events[event_type].each do |event|
          event.call arguments
        end
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
    @events || @events = RubyEvents::Events.new
  end

  def events=(events)
    @events = events
  end
end