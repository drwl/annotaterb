annotate_lib = File.expand_path(File.dirname(File.dirname(__FILE__)))

unless AnnotateRb::Env.read('is_cli')
  task :set_annotation_options
  task annotate_models: :set_annotation_options
end

desc 'Add schema information (as comments) to model and fixture files'
task annotate_models: :environment do
  require "#{annotate_lib}/annotate/annotate_models"
  require "#{annotate_lib}/annotate/active_record_patch"

  options = {is_rake: true}
  val = options[:position] = AnnotateRb::ModelAnnotator::Helper.fallback(AnnotateRb::Env.read('position'), 'before')
  AnnotateRb::Env.write('position', val)
  options[:additional_file_patterns] = AnnotateRb::Env.read('additional_file_patterns') ? AnnotateRb::Env.read('additional_file_patterns').split(',') : []
  options[:position_in_class] = AnnotateRb::ModelAnnotator::Helper.fallback(AnnotateRb::Env.read('position_in_class'), AnnotateRb::Env.read('position'))
  options[:position_in_fixture] = AnnotateRb::ModelAnnotator::Helper.fallback(AnnotateRb::Env.read('position_in_fixture'), AnnotateRb::Env.read('position'))
  options[:position_in_factory] = AnnotateRb::ModelAnnotator::Helper.fallback(AnnotateRb::Env.read('position_in_factory'), AnnotateRb::Env.read('position'))
  options[:position_in_test] = AnnotateRb::ModelAnnotator::Helper.fallback(AnnotateRb::Env.read('position_in_test'), AnnotateRb::Env.read('position'))
  options[:position_in_serializer] = AnnotateRb::ModelAnnotator::Helper.fallback(AnnotateRb::Env.read('position_in_serializer'), AnnotateRb::Env.read('position'))
  options[:show_foreign_keys] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('show_foreign_keys'))
  options[:show_complete_foreign_keys] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('show_complete_foreign_keys'))
  options[:show_indexes] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('show_indexes'))
  options[:simple_indexes] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('simple_indexes'))
  options[:model_dir] = AnnotateRb::Env.read('model_dir') ? AnnotateRb::Env.read('model_dir').split(',') : ['app/models']
  options[:root_dir] = AnnotateRb::Env.read('root_dir')
  options[:include_version] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('include_version'))
  options[:require] = AnnotateRb::Env.read('require') ? AnnotateRb::Env.read('require').split(',') : []
  options[:exclude_tests] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('exclude_tests'))
  options[:exclude_factories] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('exclude_factories'))
  options[:exclude_fixtures] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('exclude_fixtures'))
  options[:exclude_serializers] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('exclude_serializers'))
  options[:exclude_scaffolds] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('exclude_scaffolds'))
  options[:exclude_controllers] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.fetch('exclude_controllers', 'true'))
  options[:exclude_helpers] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.fetch('exclude_helpers', 'true'))
  options[:exclude_sti_subclasses] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('exclude_sti_subclasses'))
  options[:ignore_model_sub_dir] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('ignore_model_sub_dir'))
  options[:format_bare] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('format_bare'))
  options[:format_rdoc] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('format_rdoc'))
  options[:format_yard] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('format_yard'))
  options[:format_markdown] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('format_markdown'))
  options[:sort] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('sort'))
  options[:force] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('force'))
  options[:frozen] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('frozen'))
  options[:classified_sort] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('classified_sort'))
  options[:trace] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('trace'))
  options[:wrapper_open] = AnnotateRb::ModelAnnotator::Helper.fallback(AnnotateRb::Env.read('wrapper_open'), AnnotateRb::Env.read('wrapper'))
  options[:wrapper_close] = AnnotateRb::ModelAnnotator::Helper.fallback(AnnotateRb::Env.read('wrapper_close'), AnnotateRb::Env.read('wrapper'))
  options[:ignore_columns] = AnnotateRb::Env.fetch('ignore_columns', nil)
  options[:ignore_routes] = AnnotateRb::Env.fetch('ignore_routes', nil)
  options[:hide_limit_column_types] = AnnotateRb::ModelAnnotator::Helper.fallback(AnnotateRb::Env.read('hide_limit_column_types'), '')
  options[:hide_default_column_types] = AnnotateRb::ModelAnnotator::Helper.fallback(AnnotateRb::Env.read('hide_default_column_types'), '')
  options[:with_comment] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('with_comment'))
  options[:ignore_unknown_models] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.fetch('ignore_unknown_models', 'false'))

  AnnotateRb::ModelAnnotator::Annotator.do_annotations(options)
end

desc 'Remove schema information from model and fixture files'
task remove_annotation: :environment do
  require "#{annotate_lib}/annotate/annotate_models"
  require "#{annotate_lib}/annotate/active_record_patch"

  options = {is_rake: true}
  options[:model_dir] = AnnotateRb::Env.read('model_dir')
  options[:root_dir] = AnnotateRb::Env.read('root_dir')
  options[:require] = AnnotateRb::Env.read('require') ? AnnotateRb::Env.read('require').split(',') : []
  options[:trace] = AnnotateRb::ModelAnnotator::Helper.true?(AnnotateRb::Env.read('trace'))
  AnnotateRb::ModelAnnotator::Annotator.remove_annotations(options)
end
