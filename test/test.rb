require 'test/unit'
require 'ruby_events'

class TestRubyEvents < Test::Unit::TestCase
  def test_intro
    puts 'You are testing ruby_events version ' + RubyEvents::Events.version
  end
  
  def test_class_events
    assert_nothing_raised do
      example = Class.new()
      example.class_eval do
        def initialize
          events.listen(:test_event) do |event_data|
            puts 'test_class_events, 1.1: Hai there!'
          end
        end

        def call_me
          events.fire(:test_event, 'test_class_events, 1.2: My name is Mr Test Man!')
        end
      end

      e = example.new
      e.call_me # Fires the event, and our handler gets called!
    end
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

      a.inject('test_fire_on_method_custom, 1.1: This is a test.')
    end
  end
  
  def test_fire_on_method
    assert_nothing_raised do
      e = Proc.new { puts 'test_fire_on_method, 1.1: Confirm three success messages before this point.' }
      e.events.fire_on_method(:call, :called)
      e.events.listen(:called) do
        puts 'test_fire_on_method, 1.2: This message confirms a single block is triggered.'
      end
      e.events.listen(:called, Proc.new { puts 'test_fire_on_method, 1.3: This message confirms a single Proc is triggered.' })
      e.events.listen(:called, [Proc.new { puts 'test_fire_on_method, 1.4: This message confirms Proc array events are triggered.' }])
      e.call
    end
    assert_nothing_raised do
      a = []
      a.events.fire_on_method('<<'.to_sym, :item_injected)
      a.events.listen(:item_injected) do |event_data|
        puts 'test_fire_on_method, 2.1: This confirms Array class fire_on_method';
      end

      a << 'test_fire_on_method, 2.2: This is the Array class fire_on_method test data'
    end
    assert_nothing_raised do
      a = {:one => 1}
      b = {:two => 3}

      a.events.fire_on_method(:merge, :merged)
      a.events.listen(:merged) do |items|
        items[:three] = 3
        puts 'test_fire_on_method, 3.1: The hash will have the extra item.'
        items
      end

      puts a.merge(b)
    end
    
    assert_nothing_raised do
      a = {:one => 1}
      b = {:two => 3}

      a.events.fire_on_method(:merge, :merged) do
        puts 'test_fire_on_method, 4.1: Block triggered by fire_on_method.'
      end
      a.events.listen(:merged) do |items|
        items[:three] = 3
        puts 'test_fire_on_method, 4.2: The hash will have the extra item.'
        items
      end

      puts a.merge(b)
    end
  end
end

