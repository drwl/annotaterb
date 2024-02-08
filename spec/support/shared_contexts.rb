# frozen_string_literal: true

require "tmpdir"

RSpec.shared_context "isolated environment" do
  # Taken from Rubocop's shared_contexts.rb
  around do |example|
    Dir.mktmpdir do |tmpdir|
      # Make sure to expand all symlinks in the path first. Otherwise we may
      # get mismatched pathnames when loading config files later on.
      tmpdir = File.realpath(tmpdir)

      working_dir = File.join(tmpdir, "work")
      begin
        FileUtils.mkdir_p(working_dir)

        Dir.chdir(working_dir) { example.run }
      end
    end
  end
end
