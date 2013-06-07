require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rdoc/task'

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'gc_hacks'
  rdoc.options << '--line-numbers' << '--inline-source' << '--quiet'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :rdoc
