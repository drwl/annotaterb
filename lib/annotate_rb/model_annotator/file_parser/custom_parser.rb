# frozen_string_literal: true

require "ripper"

module AnnotateRb
  module ModelAnnotator
    module FileParser
      class CustomParser < Ripper
        # Overview of Ripper: https://kddnewton.com/2022/02/14/formatting-ruby-part-1.html
        # Ripper API: https://kddnewton.com/ripper-docs/events

        class << self
          def parse(string)
            _parser = new(string).tap(&:parse)
          end
        end

        attr_reader :comments

        def initialize(input, ...)
          super
          @_input = input
          @comments = []
          @block_starts = []
          @block_ends = []
          @const_type_map = {}
        end

        def starts
          @block_starts
        end

        def ends
          @block_ends
        end

        def type_map
          @const_type_map
        end

        def on_program(...)
          {
            comments: @comments,
            starts: @block_starts,
            ends: @block_ends,
            type_map: @const_type_map
          }
        end

        def on_const_ref(const)
          @block_starts << [const, lineno]
          super
        end

        # Used for `class Foo::User`
        def on_const_path_ref(_left, const)
          @block_starts << [const, lineno]
          super
        end

        def on_module(const, _bodystmt)
          @const_type_map[const] = :module unless @const_type_map[const]
          @block_ends << [const, lineno]
          super
        end

        def on_class(const, _superclass, _bodystmt)
          @const_type_map[const] = :class unless @const_type_map[const]
          @block_ends << [const, lineno]
          super
        end

        def on_embdoc_beg(value)
          @comments << [value.strip, lineno]
          super
        end

        def on_embdoc_end(value)
          @comments << [value.strip, lineno]
          super
        end

        def on_embdoc(value)
          @comments << [value.strip, lineno]
          super
        end

        def on_comment(value)
          @comments << [value.strip, lineno]
          super
        end
      end
    end
  end
end
