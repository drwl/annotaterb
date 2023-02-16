# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "files/version"

Gem::Specification.new do |s|
  s.name        = "files"
  s.version     = Files::VERSION
  s.authors     = ["Alex Chaffee"]
  s.email       = ["alex@stinky.com"]
  s.homepage    = ""
  s.summary     = %q{a simple DSL for creating temporary files and directories}
  s.description = %q{Ever want to create a whole bunch of files at once? Like when you're writing tests for a tool that processes files? The Files gem lets you cleanly specify those files and their contents inside your test code, instead of forcing you to create a fixture directory and check it in to your repo. It puts them in a temporary directory and cleans up when your test is done.}

  s.rubyforge_project = "files"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
