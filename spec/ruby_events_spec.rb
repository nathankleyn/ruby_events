require File.join(File.dirname(__FILE__), '../lib/ruby_events/core')

describe RubyEvents do

  it "should not patch object when only the core is required" do
    Object.respond_to?(:events).should be_false
  end
  
  it "should require the object patch seperate to the core" do
    require File.join(File.dirname(__FILE__), '../lib/ruby_events/object_patch').should be_true
  end

  it "should fire and handle an event correctly" do
    expect do
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

      e.event_called.should be_true
    end.to_not(raise_error)
  end

  it "should fire a custom injected event for a native method" do
    expect do
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

      event_called.should be_true
      a.should include('test')
    end.to_not(raise_error)
  end
  
  it "should fire events on a method callback" do
    expect do
      p, block_called, proc_called, proc_a_called = Proc.new {}, false, false, false
      p.events.fire_on_method(:call, :called)
      p.events.listen(:called) do
        block_called = true
      end

      p.events.listen(:called, Proc.new { proc_called = true })
      p.events.listen(:called, [Proc.new { proc_a_called = true }])
      p.call

      block_called.should be_true
      proc_called.should be_true
      proc_a_called.should be_true
    end.to_not(raise_error)
    
    expect do
      a, event_called, event_item = [], false, nil
      a.events.fire_on_method('<<'.to_sym, :injected)
      a.events.listen(:injected) do |item|
        event_called, event_item = true, item
      end

      a << 'test'

      event_called.should be_true
      event_item.should == 'test'
      a.should include('test')
    end.to_not(raise_error)

    expect do
      a, b, event_called = {:one => 1}, {:two => 3}, false

      a.events.fire_on_method(:merge, :merged)
      a.events.listen(:merged) do |items|
        event_called, items[:three] = true, 3
        items
      end

      a = a.merge(b)

      event_called.should be_true
      a.should include(:three)
    end.to_not(raise_error)
    
    expect do
      a, b, event_called, block_called = {:one => 1}, {:two => 3}, false, false

      a.events.fire_on_method(:merge, :merged) do |items|
        block_called, items[:three] = true, 3
      end
      
      a.events.listen(:merged) do |items|
        event_called, items[:four] = true, 4
        items
      end

      a = a.merge(b)
      
      block_called.should be_true
      event_called.should be_true
      a.should include(:three)
      a.should include(:four)
    end.to_not(raise_error)
  end
  
  it "should fire two events when an array of symbols is passed to fire_on_method" do
    expect do
      a, calls = [], 0
      
      a.events.fire_on_method(["<<".to_sym, :push], :item_added)
      a.events.listen(:item_added) do
        calls += 1
      end
      
      a << "hello"
      a.push "world"

      calls.should == 2
    end.to_not(raise_error)
  end
  
  it "should not call a removed event" do
    expect do
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
      
      e.event_called.should be_false
    end.to_not(raise_error)

    expect do
      a, b, event_called = {:one => 1}, {:two => 2}, false

      a.events.fire_on_method(:merge, :merged)
      a.events.listen(:merged) do |items|
        event_called = true
      end

      a.events.remove_fire_on_method(:merge)
      a = a.merge(b)

      event_called.should be_false
    end.to_not(raise_error)
  end
end
