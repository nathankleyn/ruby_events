Use ruby_events to add event listening and firing capabilities to all Ruby
objects. It's simple, fast and remains Ruby-ish in style and usage.

## Installation

    gem install ruby_events

## Usage

Using ruby_events is simple! Because all objects are automatically extended
with the ruby_events functionality, it's as simple as:

    require 'ruby_events'

    x = Object.new
    x.events.listen :test_event, Proc.new {|data_passed| puts 'hai!'; puts data_passed }
    x.events.fire :test_event, :test_data => 'hello', :more_test_data => 'hey'

All ruby_events functionality is just an object.events call away.