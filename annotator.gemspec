Gem::Specification.new do |spec|
  spec.name          = "Annotator"
  spec.version       = File.read("VERSION").strip
  spec.authors       = ["Andrew W. Lee"]
  spec.email         = ["git@drewlee.com"]

  spec.summary       = <<~SUMMARY.strip
    A gem for generating annotations for Rails projects.
  SUMMARY
  spec.description   = <<~DESCRIPTION.strip
    Annotates Rails/ActiveRecord Models, routes, fixtures, and others based on the database schema.
  DESCRIPTION
  spec.homepage      = "https://github.com/drwl/lib-old-new"
  spec.license       = "2-clause BSDL"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/drwl/annotator"
  spec.metadata["changelog_uri"] = "https://github.com/drwl/annotator/blob/master/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/drwl/annotator/issues"

  spec.files         = Dir["VERSION", "CHANGELOG.md", "LICENSE.txt", "README.md", "lib/**/*", "bin/**/*"]
  spec.bindir        = "exe"
  spec.executables   = Dir["exe/*"].map { |exe| File.basename(exe) }
  spec.require_paths = ["lib"]
end