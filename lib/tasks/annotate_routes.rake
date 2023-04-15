annotate_lib = File.expand_path(File.dirname(File.dirname(__FILE__)))

# TODO: Remove this instance; Decide what to do with this
unless AnnotateRb::Env.read('is_cli')
  task :set_annotation_options
  task annotate_routes: :set_annotation_options
end

desc "Adds the route map to routes.rb"
task :annotate_routes => :environment do
  require "#{annotate_lib}/annotate/annotate_routes"

  options = {}

  AnnotateRb::RouteAnnotator::Annotator.add_annotations(options)
end

desc "Removes the route map from routes.rb"
task :remove_routes => :environment do
  annotate_lib = File.expand_path(File.dirname(File.dirname(__FILE__)))
  require "#{annotate_lib}/annotate/annotate_routes"

  options = {}

  AnnotateRb::RouteAnnotator::Annotator.remove_annotations(options)
end
