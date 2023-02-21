# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class PatternGetter
      class << self
        def call(options, pattern_types = [])
          current_patterns = []

          options[:root_dir].each do |root_directory|
            Array(pattern_types).each do |pattern_type|
              patterns = FilePatterns.generate(root_directory, pattern_type, options)

              current_patterns += if pattern_type.to_sym == :additional_file_patterns
                                    patterns
                                  else
                                    patterns.map { |p| p.sub(/^[\/]*/, '') }
                                  end
            end
          end

          current_patterns
        end
      end
    end
  end
end
