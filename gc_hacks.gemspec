# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gc_hacks/version"

Gem::Specification.new do |s|
  s.name        = "gc_hacks"
  s.version     = GCHacks::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Stefan Kaes"]
  s.email       = ["skaes@railsexpress.de"]
  s.homepage    = "https://github.com/skaes/gc_hacks"
  s.summary     = %q{GC tracing/Heap dumping support for Rails processes}
  s.description = %q{This gem allows you to send GC related commands to a running Rails process}

  s.rubyforge_project = "gc_hacks"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
