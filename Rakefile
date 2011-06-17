require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rdoc/task'
require 'rspec/core/rake_task'

RDoc::Task.new do |rdoc|
  files =['README.markdown', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.markdown" # page to start on
  rdoc.title = "ruby_events Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

RSpec::Core::RakeTask.new(:spec)
