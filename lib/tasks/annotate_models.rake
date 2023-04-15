annotate_lib = File.expand_path(File.dirname(File.dirname(__FILE__)))

unless AnnotateRb::Env.read('is_cli')
  task :set_annotation_options
  task annotate_models: :set_annotation_options
end

desc 'Add schema information (as comments) to model and fixture files'
task annotate_models: :environment do
  require "#{annotate_lib}/annotate/annotate_models"
  require "#{annotate_lib}/annotate/active_record_patch"

  options = { is_rake: true }

  AnnotateRb::ModelAnnotator::Annotator.do_annotations(options)
end

desc 'Remove schema information from model and fixture files'
task remove_annotation: :environment do
  require "#{annotate_lib}/annotate/annotate_models"
  require "#{annotate_lib}/annotate/active_record_patch"

  options = { is_rake: true }

  AnnotateRb::ModelAnnotator::Annotator.remove_annotations(options)
end
