require 'ruby_events'

e = Proc.new { puts 'test' }
e.events.fire_on_method(:call, :called)
e.events.listen(:called) do
  puts 'We got the funk.'
end
puts e.call

################################################################################

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


################################################################################

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

################################################################################

a = []
a.events.fire_on_method('<<'.to_sym, :item_injected)
a.events.listen(:injected) do |event_data|
  puts event_data;
end

a << 'this is a test'

################################################################################

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
