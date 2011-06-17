require 'test/unit'

# Note that this is kind of kludgy, for lack of a better way to do it at the
# moment; the classes are named as such so that the first class in this document
# always runs first in order for the require's not to mess up the tests.

class TestCoreRubyEvents < Test::Unit::TestCase

  def setup
    require File.join(File.dirname(__FILE__), '../lib/ruby_events/core')
  end

  def test_no_patch_on_object
    assert(Object.respond_to?(:events) === false, "Object should not have been extended with RubyEvents.")
  end
  
end

class TestCoreWithObjectPatchRubyEvents < Test::Unit::TestCase

  def setup
    require File.join(File.dirname(__FILE__), '../lib/ruby_events/object_patch')
  end
  
  def test_class_events
    assert_nothing_raised do
      example = Class.new()
      example.class_eval do
        attr_accessor :event_called

        def initialize
          events.listen(:test_event) do
            @event_called = true
          end
        end

        def call_me
          events.fire(:test_event)
        end
      end

      e = example.new
      e.call_me
      
      assert(e.event_called, 'Event called should be true indicating event has fired and been handled correctly.')
    end
  end
  
  def test_fire_on_method_custom
    assert_nothing_raised do
      a, event_called = [], false
      
      class << a
        alias_method :inject_old, '<<'.to_sym
        
        def <<(item)
          events.fire(:injected, self, item)
          inject_old(item)
        end
      end

      a.events.listen(:injected) do |a, item|
        event_called = true
      end

      a << 'test'
      
      assert(event_called, 'Event called should be true indicating event has fired and been handled correctly.')
      assert(a.include?('test'), 'Array should have new object inside it.')
    end
  end
  
  def test_fire_on_method
    assert_nothing_raised do
      p, block_called, proc_called, proc_a_called = Proc.new {}, false, false, false
      p.events.fire_on_method(:call, :called)
      p.events.listen(:called) do
        block_called = true
      end
      
      p.events.listen(:called, Proc.new { proc_called = true })
      p.events.listen(:called, [Proc.new { proc_a_called = true }])
      p.call

      assert(block_called, 'Block passed to listener should be called.')
      assert(proc_called, 'Proc passed to listener should be called.')
      assert(proc_a_called, 'Array of Proc\'s passed to listener should be called.')
    end
    
    assert_nothing_raised do
      a, event_called, event_item = [], false, nil
      a.events.fire_on_method('<<'.to_sym, :injected)
      a.events.listen(:injected) do |item|
        event_called, event_item = true, item
      end

      a << 'test'

      assert(event_called, 'Event called should be true indicating event has fired and been handled correctly.')
      assert(event_item == 'test', 'Item passed to callback should be argument of original function.')
      assert(a.include?('test'), 'Array should have originally intended injected item inside it.')
    end

    assert_nothing_raised do
      a, b, event_called = {:one => 1}, {:two => 3}, false

      a.events.fire_on_method(:merge, :merged)
      a.events.listen(:merged) do |items|
        event_called, items[:three] = true, 3
        items
      end

      a = a.merge(b)

      assert(event_called, 'Event called should be true indicating event has fired and been handled correctly.')
      assert(a.include?(:three), 'The hash passed should have the extra item.')
    end
    
    assert_nothing_raised do
      a, b, event_called, block_called = {:one => 1}, {:two => 3}, false, false

      a.events.fire_on_method(:merge, :merged) do |items|
        block_called, items[:three] = true, 3
      end
      
      a.events.listen(:merged) do |items|
        event_called, items[:four] = true, 4
        items
      end

      a = a.merge(b)

      assert(block_called, 'Block called should be true indicating block has been processed correctly between fire of event and callback instantiation.')
      assert(event_called, 'Event called should be true indicating event has fired and been handled correctly.')
      assert(a.include?(:three), 'The hash passed should have the extra item from block.')
      assert(a.include?(:four), 'The hash passed should have the extra item from callback.')
    end
  end
  
  def test_fire_on_multiple_methods
    assert_nothing_raised do
      a, calls = [], 0
      
      a.events.fire_on_method(["<<".to_sym, :push], :item_added)
      a.events.listen(:item_added) do
        calls += 1
      end
      
      a << "hello"
      a.push "world"

      assert(calls == 2, 'There should be two events fired, one for each symbol passed in the array of methods to fire on.')
    end
  end

  def test_remove_events
    assert_nothing_raised do
      example = Class.new()
      example.class_eval do
        attr_accessor :event_called, :p

        def initialize
          @p = Proc.new { @event_called = true }
          events.listen(:test_event, @p)
        end

        def call_me
          events.fire(:test_event)
        end
      end
      
      e = example.new
      e.events.remove(:test_event, e.p)
      e.call_me
      
      assert(!e.event_called, 'Event called should be false, as the event was removed before being triggered.')
    end

    assert_nothing_raised do
      a, b, event_called = {:one => 1}, {:two => 2}, false

      a.events.fire_on_method(:merge, :merged)
      a.events.listen(:merged) do |items|
        event_called = true
      end

      a.events.remove_fire_on_method(:merge)
      a = a.merge(b)

      assert(!event_called, 'Event called should be false, as the event was removed before being triggered.')
    end
  end
  
end
