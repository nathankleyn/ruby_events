# RubyEvents

Use RubyEvents to add event listening and firing capabilities to all Ruby
objects. It's simple, fast and remains Ruby-ish in style and usage.

A really simple event implementation that hooks into the Object class by
default, or can be used to extend modules and classes. Now all your objects can
join in the fun of firing events! RubyEvents even offers you callbacks on
already defined methods, without having to do the hard work yourself - yes this
means you can have callbacks on standard library methods without having to
monkey patch!

## Installation

```shell
gem install ruby_events
```

## Usage

Using ruby_events is simple

```ruby
require 'rubygems'
require 'ruby_events'
```
    
By default, all Objects are extended with a RubyEvents, and given a new method
called `events`. You can also require RubyEvents without the Object patch:

```ruby
require 'rubygems'
require 'ruby_events/core'
```

This allows you to patch objects yourself, or apply the RubyEvents module
however you like.

### Examples

RubyEvents allows you to use events like callbacks, whether within your own
classes, or by monkey patching others:

```ruby
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
```

You can do cooler and more advanced things, like add listeners to an Array:

```ruby
a = []

class << a
  alias_method :inject_old, :inject
  
  def inject(item)
    events.fire(:injected, self, item)
    inject_old(item)
  end
end

a.events.listen(:injected) do |a, item|
  puts a
  puts item
end

a.inject('This is a test')
```

But because this is a fairly common pattern, RubyEvents does it for you with
a little bit of sugar:

```ruby
a = []
a.events.fire_on_method('<<'.to_sym, :item_injected)
a.events.listen(:injected) do |event_data|
  puts event_data
end

a << 'this is a test'
```
    
You can supply multiple methods to fire a single event type on, useful for
catching methods and their aliases:

```ruby
a.events.fire_on_method(['<<'.to_sym, :push], :item_injected)
```
    
You can supply the `listen` method with a Proc, an array of Procs, or a block.
You can also give it a mixute of Procs and a block if you really want:

```ruby
a = []
a.events.fire_on_method('<<'.to_sym, :item_injected)
a.events.listen(:injected, [Proc.new { |event_data| puts event_data; }, Proc.new { puts 'Hello, I was called!'; }])

a << 'this is a test'
```

These method events will automatically be passed the arguments that were passed
to that method when it was called. Don't let your imagination stop there. You
can add an event to any class method, and because all ruby objects are passed by
reference, you can set these arguments and change the outcome of the function.
Effectively, you can use the events as callbacks on any method:

```ruby
a = {:one => 1}
b = {:two => 3}

a.events.fire_on_method(:merge, :merged)
a.events.listen(:merged) do |items|
  items[:three] = 3
  puts 'The hash will have the extra item.'
  items
end

puts a.merge(b)
```

All RubyEvents functionality is just an `object.events` call away.

## Licence

The MIT License

Copyright (c) 2011 Nathan Kleyn

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
