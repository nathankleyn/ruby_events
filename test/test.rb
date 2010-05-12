require 'test/unit'
require 'ruby_events'

class TestRubyEvents < Test::Unit::TestCase
  def test_intro
    puts 'You are testing RubyEvent version ' + RubyEvents::Events.version
  end
  
  def test_class_events
#    assert_nothing_raised do
#      class Example
#        def initialize
#          events.listen(:test_event) do |event_data|
#            puts 'Hai there!'
#            puts event_data
#          end
#        end

#        def call_me
#          events.fire(:test_event, 'My name is Mr Test Man!')
#        end
#      end

#      e = Example.new
#      e.call_me # Fires the event, and our handler gets called!
#    end
  end
  
  def test_fire_on_method_custom
    assert_nothing_raised do
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

      a.inject('This is a test.')
    end
  end
  
  def test_fire_on_method
    assert_nothing_raised do
      e = Proc.new { puts 'Test 1: Confirm three success messages before this point.' }
      e.events.fire_on_method(:call, :called)
      e.events.listen(:called) do
        puts '1.1: This message confirms a single block is triggered.'
      end
      e.events.listen(:called, Proc.new { puts '1.2: This message confirms a single Proc is triggered.' })
      e.events.listen(:called, [Proc.new { puts '1.3: This message confirms Proc array events are triggered.' }])
      e.call
    end
    assert_nothing_raised do
      a = []
      a.events.fire_on_method('<<'.to_sym, :item_injected)
      a.events.listen(:injected) do |event_data|
        puts event_data;
      end

      a << 'this is a test'
    end
    assert_nothing_raised do
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
    end
  end
end

