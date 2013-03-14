require File.join(File.dirname(__FILE__), 'lib/ruby_events')

GEM_SPEC = Gem::Specification.new do |spec|
  spec.name = 'ruby_events'
  spec.version = RubyEvents::Events.version
  spec.extra_rdoc_files = ['README.markdown']
  spec.summary = 'A really simple event implementation that hooks into the Object class by default, or can be used to extend modules and classes. Now all your objects can join in the fun of firing events!'
  spec.description = spec.summary + ' See http://github.com/nathankleyn/ruby_events for more information.'
  spec.author = 'Nathan Kleyn'
  spec.email = 'nathan@unfinitydesign.com'
  spec.homepage = 'http://github.com/nathankleyn/ruby_events'
  spec.files = %w(README.markdown Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  spec.require_path = "lib"
  spec.bindir = "bin"
  
  spec.add_development_dependency("rspec", "~>2.13.0")
end
