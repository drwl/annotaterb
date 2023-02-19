annotate_lib = File.expand_path(File.dirname(File.dirname(__FILE__)))

unless AnnotateRb::Env.read('is_cli')
  task :set_annotation_options
  task annotate_routes: :set_annotation_options
end

desc "Adds the route map to routes.rb"
task :annotate_routes => :environment do
  require "#{annotate_lib}/annotate/annotate_routes"

  options={}
  val = options[:position] = Annotate::Helpers.fallback(AnnotateRb::Env.read('position'), 'before')
  Env.write('position', val)
  options[:position_in_routes] = Annotate::Helpers.fallback(AnnotateRb::Env.read('position_in_routes'), AnnotateRb::Env.read('position'))
  options[:ignore_routes] = Annotate::Helpers.fallback(AnnotateRb::Env.read('ignore_routes'),  nil)
  options[:require] = AnnotateRb::Env.read('require') ? AnnotateRb::Env.read('require').split(',') : []
  options[:wrapper_open] = Annotate::Helpers.fallback(AnnotateRb::Env.read('wrapper_open'), AnnotateRb::Env.read('wrapper'))
  options[:wrapper_close] = Annotate::Helpers.fallback(AnnotateRb::Env.read('wrapper_close'), AnnotateRb::Env.read('wrapper'))
  AnnotateRb::RouteAnnotator::Annotator.add_annotations(options)
end

desc "Removes the route map from routes.rb"
task :remove_routes => :environment do
  annotate_lib = File.expand_path(File.dirname(File.dirname(__FILE__)))
  require "#{annotate_lib}/annotate/annotate_routes"

  options={}
  options[:require] = AnnotateRb::Env.read('require') ? AnnotateRb::Env.read('require').split(',') : []
  AnnotateRb::RouteAnnotator::Annotator.remove_annotations(options)
end
