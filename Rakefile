require 'lib/ruby_events'
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rubygems/package_task'
require 'rdoc/task'
require 'rake/testtask'

spec = Gem::Specification.new do |s|
  s.name = 'ruby_events'
  s.version = RubyEvents::Events.version
  s.extra_rdoc_files = ['README.markdown']
  s.summary = 'A really simple event implementation that hooks into the Object class. Now all your objects can join in the fun of firing events!'
  s.description = s.summary + ' See http://github.com/nathankleyn/ruby_events for more information.'
  s.author = 'Nathan Kleyn'
  s.email = 'nathan@unfinitydesign.com'
  s.homepage = 'http://github.com/nathankleyn/ruby_events'
  # s.executables = ['your_executable_here']
  s.files = %w(README.markdown Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end

Gem::PackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

RDoc::Task.new do |rdoc|
  files =['README.markdown', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.markdown" # page to start on
  rdoc.title = "ruby_events Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end
