# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::FileParser::YmlParser do
  subject { described_class.parse(input) }

  def check_it_parses_correctly
    expect(subject.comments).to eq(expected_comments)
    expect(subject.starts).to eq(expected_starts)
    expect(subject.ends).to eq(expected_ends)
  end

  context "with a valid yml file" do
    let(:input) do
      <<~FILE
        foo:
          boolean: true
          string: foo

        bar:
          boolean: false
          string: bar

      FILE
    end
    let(:expected_comments) { [] }
    let(:expected_starts) { [[nil, 0]] }
    let(:expected_ends) { [[nil, 8]] }

    it "parses correctly" do
      check_it_parses_correctly
    end
  end

  context "with a valid yml file with comments" do
    let(:input) do
      <<~FILE
        #
        # Table name: test_defaults
        #
        #  id         :integer          not null, primary key
        #  boolean    :boolean          default(FALSE)
        #  string     :string           default("hello world!")
        #  created_at :datetime         not null
        #  updated_at :datetime         not null
        #
        foo:
          boolean: true
          string: foo

        bar:
          boolean: false
          string: bar

      FILE
    end
    let(:expected_comments) do
      [
        ["#", 0],
        ["# Table name: test_defaults", 1],
        ["#", 2],
        ["#  id         :integer          not null, primary key", 3],
        ["#  boolean    :boolean          default(FALSE)", 4],
        ["#  string     :string           default(\"hello world!\")", 5],
        ["#  created_at :datetime         not null", 6],
        ["#  updated_at :datetime         not null", 7],
        ["#", 8]
      ]
    end
    let(:expected_starts) { [[nil, 9]] }
    let(:expected_ends) { [[nil, 17]] }

    it "parses correctly" do
      check_it_parses_correctly
    end
  end

  context "with a yml file that only has comments" do
    let(:input) do
      <<~FILE
        #
        # Table name: test_defaults
        #
        #  id         :integer          not null, primary key
        #  boolean    :boolean          default(FALSE)
        #  string     :string           default("hello world!")
        #  created_at :datetime         not null
        #  updated_at :datetime         not null
        #
      FILE
    end
    let(:expected_comments) do
      [
        ["#", 0],
        ["# Table name: test_defaults", 1],
        ["#", 2],
        ["#  id         :integer          not null, primary key", 3],
        ["#  boolean    :boolean          default(FALSE)", 4],
        ["#  string     :string           default(\"hello world!\")", 5],
        ["#  created_at :datetime         not null", 6],
        ["#  updated_at :datetime         not null", 7],
        ["#", 8]
      ]
    end
    let(:expected_starts) { [[nil, 9]] }
    let(:expected_ends) { [[nil, 9]] }

    it "parses correctly" do
      check_it_parses_correctly
    end
  end

  context "with a yml file that has erb" do
    let(:input) do
      <<~FILE
        # Read about fixtures at https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html

        <% 1.upto(100) do |i| %>
        user_<%= i %>:
          name: User <%= i %>
          email: user_<%= i %>@example.com
        <% end %>

      FILE
    end
    let(:expected_comments) do
      [
        ["# Read about fixtures at https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html", 0]
      ]
    end
    # Content bounds are taken from the original file (not the evaluated ERB),
    # so the annotation is placed around the ERB body instead of inside a tag.
    let(:expected_starts) { [[nil, 2]] }
    let(:expected_ends) { [[nil, 7]] }

    it "parses without errors" do
      check_it_parses_correctly
    end
  end

  context "with a yml file that starts with a multi-line erb block" do
    let(:input) do
      <<~FILE
        <%
          total = 2
        %>
        <% total.times do |i| %>
        user_<%= i %>:
          name: User <%= i %>
        <% end %>
      FILE
    end
    let(:expected_comments) { [] }
    # Start must be line 0 (the opening `<%`) so the annotation is written
    # above the ERB block, not inside it.
    let(:expected_starts) { [[nil, 0]] }
    let(:expected_ends) { [[nil, 7]] }

    it "parses without inserting into the erb block" do
      check_it_parses_correctly
    end
  end

  context "with malformed yaml that is not an erb fixture" do
    let(:input) do
      <<~FILE
        user_one: [
      FILE
    end

    it "re-raises the parse error instead of silently annotating" do
      expect { described_class.parse(input) }.to raise_error(Psych::SyntaxError)
    end
  end

  context "with an empty yml file" do
    let(:input) do
      <<~FILE
      FILE
    end
    let(:expected_comments) { [] }
    let(:expected_starts) { [[nil, 0]] }
    let(:expected_ends) { [[nil, 0]] }

    it "parses correctly" do
      check_it_parses_correctly
    end
  end
end
