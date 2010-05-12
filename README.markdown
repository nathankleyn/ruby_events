Use ruby_events to add event listening and firing capabilities to all Ruby
objects. It's simple, fast and remains Ruby-ish in style and usage.

## Installation

    gem install ruby_events

## Usage

Using ruby_events is simple! Because all objects are automatically extended
with the ruby_events functionality, it's as simple as:

    require 'rubygems'
    require 'ruby_events'

    class Example
      def initialize
        events.listen(:test_event) do |event_data|
          puts 'Hai there!'
          puts event_data
        end
      end

      def call_me
        events.fire(:test_event, 'My name is Mr Test Man!')
      end
    end

    e = Example.new
    e.call_me # Fires the event, and our handler gets called!

You can do cooler and more advanced things, like add listeners to an Array:

    a = []
    
    class << a
      alias_method :inject_old, :inject
      
      def inject(item)
        events.fire(:injected, self, item)
        inject_old(item)
      end
    end

    a.events.listen(:injected) do |event_data|
      puts event_data;
    end
    
    a.inject('This is a test')

But because this is a fairly common pattern, ruby_events does it for you with
a little bit of sugar:

    a = []
    a.events.fire_on_method('<<'.to_sym, :item_injected)
    a.events.listen(:injected) do |event_data|
      puts event_data;
    end
    
    a << 'this is a test'
    
You can supply the `listen` method with a Proc, an array of Procs, or a block.
You can also give it a mixute of Procs and a block if you really want:

    a = []
    a.events.fire_on_method('<<'.to_sym, :item_injected)
    a.events.listen(:injected, [Proc.new { |event_data| puts event_data; }, Proc.new { puts 'Hello, I was called!'; }])
    
    a << 'this is a test'

These method events will automatically be passed the arguments that were passed
to that method when it was called. Don't let your imagination stop there. You
can add an event to any class method, and because all ruby objects are passed by
reference, you can set these arguments and change the outcome of the function.
Effectively, you can use the events as callbacks on any method:

    a = {:one => 1}
    b = {:two => 3}

    a.events.fire_on_method(:merge, :merged)
    a.events.listen(:merged) do |items|
      # This is the hard part: because the items variable is actually just an
      # array of all variables passed to the function that fired the event,
      # you need to access the argument you're interested in; in this case,
      # Hash.merge only takes one argument, and we'll be using it.
      items[0][:three] = 3
      puts 'The hash will have the extra item.'
      items
    end

    puts a.merge(b)

All ruby_events functionality is just an object.events call away.
