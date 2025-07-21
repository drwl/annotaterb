RSpec.describe AnnotateRb::ModelAnnotator::Annotation::AnnotationBuilder do
  include AnnotateTestHelpers

  describe "#build" do
    subject do
      described_class.new(klass, options).build
    end

    let :klass do
      mock_class(:users, primary_key, columns, indexes, foreign_keys)
    end
    let :indexes do
      []
    end
    let :foreign_keys do
      []
    end

    context "integration test" do
      let(:klass) do
        primary_key = :id
        columns = [
          mock_column("id", :integer),
          mock_column("age", :integer),
          mock_column("foreign_thing_id", :integer)
        ]
        indexes = [
          mock_index("index_rails_02e851e3b7", columns: ["id"]),
          mock_index("index_rails_02e851e3b8", columns: ["foreign_thing_id"])
        ]
        foreign_keys = [
          mock_foreign_key("fk_rails_cf2568e89e", "foreign_thing_id", "foreign_things"),
          mock_foreign_key("custom_fk_name", "other_thing_id", "other_things"),
          mock_foreign_key("fk_rails_a70234b26c", "third_thing_id", "third_things")
        ]

        check_constraints = [
          mock_check_constraint("alive", "age < 150"),
          mock_check_constraint("must_be_adult", "age >= 18"),
          mock_check_constraint("missing_expression", nil),
          mock_check_constraint("multiline_test", <<~SQL)
            CASE
              WHEN (age >= 18) THEN (age <= 21)
              ELSE true
            END
          SQL
        ]

        custom_connection = mock_connection(indexes, foreign_keys, check_constraints)
        mock_class_with_custom_connection(:users, primary_key, columns, custom_connection)
      end

      let(:options) do
        AnnotateRb::Options.new({
          show_indexes: true,
          with_comment: true,
          with_table_comments: true,
          with_column_comments: true,
          show_foreign_keys: true,
          show_check_constraints: true
        })
      end

      let :expected_result do
        <<~EOS
          # == Schema Information
          #
          # Table name: users
          #
          #  id               :integer          not null, primary key
          #  age              :integer          not null
          #  foreign_thing_id :integer          not null
          #
          # Indexes
          #
          #  index_rails_02e851e3b7  (id)
          #  index_rails_02e851e3b8  (foreign_thing_id)
          #
          # Foreign Keys
          #
          #  custom_fk_name  (other_thing_id => other_things.id)
          #  fk_rails_...    (foreign_thing_id => foreign_things.id)
          #  fk_rails_...    (third_thing_id => third_things.id)
          #
          # Check Constraints
          #
          #  alive               (age < 150)
          #  missing_expression
          #  multiline_test      (CASE WHEN (age >= 18) THEN (age <= 21) ELSE true END)
          #  must_be_adult       (age >= 18)
          #
        EOS
      end

      it "matches the expected result" do
        is_expected.to eq expected_result
      end
    end

    context "with primary key and using globalize gem" do
      let :options do
        AnnotateRb::Options.new({})
      end

      let :primary_key do
        :id
      end

      let :translation_klass do
        double("Post::Translation",
          to_s: "Post::Translation",
          columns: [
            mock_column("id", :integer, limit: 8),
            mock_column("post_id", :integer, limit: 8),
            mock_column("locale", :string, limit: 50),
            mock_column("title", :string, limit: 50)
          ])
      end

      let :klass do
        mock_class(:posts, primary_key, columns, indexes, foreign_keys).tap do |mock_klass|
          allow(mock_klass).to receive(:translation_class).and_return(translation_klass)
          allow(mock_klass).to receive(:name).and_return(double("name", foreign_key: double("foreign_key", to_sym: :post_id)))
        end
      end

      let :columns do
        [
          mock_column("id", :integer, limit: 8),
          mock_column("author_name", :string, limit: 50)
        ]
      end

      let :expected_result do
        <<~EOS
          # == Schema Information
          #
          # Table name: posts
          #
          #  id          :integer          not null, primary key
          #  author_name :string(50)       not null
          #  title       :string(50)       not null
          #
        EOS
      end

      it "returns schema info" do
        is_expected.to eq(expected_result)
      end
    end

    context 'when "classified_sort" is true' do
      let :primary_key do
        :id
      end

      let :options do
        AnnotateRb::Options.new({classified_sort: true})
      end

      let :columns do
        [
          mock_column("active", :boolean, limit: 1),
          mock_column("name", :string, limit: 50),
          mock_column("notes", :text, limit: 55)
        ]
      end

      let :expected_result do
        <<~EOS
          # == Schema Information
          #
          # Table name: users
          #
          #  active :boolean          not null
          #  name   :string(50)       not null
          #  notes  :text(55)         not null
          #
        EOS
      end

      it 'works with option "classified_sort"' do
        is_expected.to eq expected_result
      end

      context "when default timestamps are included" do
        let(:columns) do
          [
            mock_column("parent_id", :integer),
            mock_column("updated_at", :datetime),
            mock_column("name", :string),
            mock_column("id", :integer),
            mock_column("deleted_at", :datetime),
            mock_column("created_at", :datetime)
          ]
        end

        it "sorts default timestamps second last before associations" do
          is_expected.to eq <<~EOS
            # == Schema Information
            #
            # Table name: users
            #
            #  id         :integer          not null, primary key
            #  deleted_at :datetime         not null
            #  name       :string           not null
            #  created_at :datetime         not null
            #  updated_at :datetime         not null
            #  parent_id  :integer          not null
            #
          EOS
        end

        context "when timestamps_column option is set" do
          let(:options) do
            AnnotateRb::Options.new(
              classified_sort: true,
              timestamp_columns: %w[created_at updated_at deleted_at]
            )
          end

          it "sorts configured timestamps into config order" do
            is_expected.to eq <<~EOS
              # == Schema Information
              #
              # Table name: users
              #
              #  id         :integer          not null, primary key
              #  name       :string           not null
              #  created_at :datetime         not null
              #  updated_at :datetime         not null
              #  deleted_at :datetime         not null
              #  parent_id  :integer          not null
              #
            EOS
          end
        end
      end

      context "when polymorphic associations are present" do
        let(:columns) do
          [
            mock_column("id", :uuid),
            mock_column("account_id", :uuid),
            mock_column("user_id", :uuid),
            mock_column("artifact_type", :string),
            mock_column("artifact_id", :uuid),
            mock_column("provider", :string),
            mock_column("model", :string),
            mock_column("created_at", :datetime),
            mock_column("updated_at", :datetime)
          ]
        end

        context "when grouped_polymorphic is false" do
          let(:options) do
            AnnotateRb::Options.new(classified_sort: true, grouped_polymorphic: false)
          end

          it "places polymorphic _type columns together with their _id columns in associations section" do
            expected = <<~EOS
              # == Schema Information
              #
              # Table name: users
              #
              #  id            :uuid             not null, primary key
              #  artifact_type :string           not null
              #  model         :string           not null
              #  provider      :string           not null
              #  created_at    :datetime         not null
              #  updated_at    :datetime         not null
              #  account_id    :uuid             not null
              #  artifact_id   :uuid             not null
              #  user_id       :uuid             not null
              #
            EOS

            is_expected.to eq expected
          end
        end

        context "when grouped_polymorphic is true" do
          let(:options) do
            AnnotateRb::Options.new(classified_sort: true, grouped_polymorphic: true)
          end

          it "sorts polymorphic _type columns with the other columns" do
            expected = <<~EOS
              # == Schema Information
              #
              # Table name: users
              #
              #  id            :uuid             not null, primary key
              #  model         :string           not null
              #  provider      :string           not null
              #  created_at    :datetime         not null
              #  updated_at    :datetime         not null
              #  account_id    :uuid             not null
              #  artifact_id   :uuid             not null
              #  artifact_type :string           not null
              #  user_id       :uuid             not null
              #
            EOS

            is_expected.to eq expected
          end
        end
      end
    end

    context "when geometry columns are included" do
      let :primary_key do
        :id
      end

      let :options do
        AnnotateRb::Options.new({classified_sort: false, with_comment: true})
      end

      let :columns do
        [
          mock_column("id", :integer, limit: 8),
          mock_column("active", :boolean, default: false, null: false),
          mock_column("geometry", :geometry,
            geometric_type: "Geometry", srid: 4326,
            limit: {srid: 4326, type: "geometry"}),
          mock_column("location", :geography,
            geometric_type: "Point", srid: 0,
            limit: {srid: 0, type: "geometry"})
        ]
      end

      let :expected_result do
        <<~EOS
          # == Schema Information
          #
          # Table name: users
          #
          #  id       :integer          not null, primary key
          #  active   :boolean          default(FALSE), not null
          #  geometry :geometry         not null, geometry, 4326
          #  location :geography        not null, point, 0
          #
        EOS
      end

      it 'works with option "with_comment"' do
        is_expected.to eq expected_result
      end
    end

    context 'when option "format_rdoc" is true' do
      let :primary_key do
        :id
      end

      let :options do
        AnnotateRb::Options.new({format_rdoc: true})
      end

      let :columns do
        [
          mock_column("id", :integer),
          mock_column("name", :string, limit: 50)
        ]
      end

      let :expected_result do
        <<~EOS
          # == Schema Information
          #
          # Table name: users
          #
          # *id*::   <tt>integer, not null, primary key</tt>
          # *name*:: <tt>string(50), not null</tt>
          #--
          # == Schema Information End
          #++
        EOS
      end

      it "returns schema info in RDoc format" do
        is_expected.to eq(expected_result)
      end
    end

    context 'when option "format_yard" is true' do
      let :primary_key do
        :id
      end

      let :options do
        AnnotateRb::Options.new({format_yard: true})
      end

      let :columns do
        [
          mock_column("id", :integer),
          mock_column("name", :string, limit: 50)
        ]
      end

      let :expected_result do
        <<~EOS
          # == Schema Information
          #
          # Table name: users
          #
          # @!attribute id
          #   @return [Integer]
          # @!attribute name
          #   @return [String]
          #
        EOS
      end

      it "returns schema info in YARD format" do
        is_expected.to eq(expected_result)
      end
    end

    context 'when option "format_markdown" is true' do
      context "when other option is not specified" do
        let :primary_key do
          :id
        end

        let :options do
          AnnotateRb::Options.new({format_markdown: true})
        end

        let :columns do
          [
            mock_column("id", :integer),
            mock_column("name", :string, limit: 50)
          ]
        end

        let :expected_result do
          <<~EOS
            # ## Schema Information
            #
            # Table name: `users`
            #
            # ### Columns
            #
            # Name        | Type               | Attributes
            # ----------- | ------------------ | ---------------------------
            # **`id`**    | `integer`          | `not null, primary key`
            # **`name`**  | `string(50)`       | `not null`
            #
          EOS
        end

        it "returns schema info in Markdown format" do
          is_expected.to eq(expected_result)
        end
      end

      context 'when option "show_indexes" is true' do
        let :primary_key do
          :id
        end

        let :options do
          AnnotateRb::Options.new({format_markdown: true, show_indexes: true})
        end

        let :columns do
          [
            mock_column("id", :integer),
            mock_column("name", :string, limit: 50)
          ]
        end

        context "when indexes are normal" do
          let :indexes do
            [
              mock_index("index_rails_02e851e3b7", columns: ["id"]),
              mock_index("index_rails_02e851e3b8", columns: ["foreign_thing_id"])
            ]
          end

          let :expected_result do
            <<~EOS
              # ## Schema Information
              #
              # Table name: `users`
              #
              # ### Columns
              #
              # Name        | Type               | Attributes
              # ----------- | ------------------ | ---------------------------
              # **`id`**    | `integer`          | `not null, primary key`
              # **`name`**  | `string(50)`       | `not null`
              #
              # ### Indexes
              #
              # * `index_rails_02e851e3b7`:
              #     * **`id`**
              # * `index_rails_02e851e3b8`:
              #     * **`foreign_thing_id`**
              #
            EOS
          end

          it "returns schema info with index information in Markdown format" do
            is_expected.to eq expected_result
          end
        end

        context 'when one of indexes includes "unique" clause' do
          let :indexes do
            [
              mock_index("index_rails_02e851e3b7", columns: ["id"]),
              mock_index("index_rails_02e851e3b8",
                columns: ["foreign_thing_id"],
                unique: true)
            ]
          end

          let :expected_result do
            <<~EOS
              # ## Schema Information
              #
              # Table name: `users`
              #
              # ### Columns
              #
              # Name        | Type               | Attributes
              # ----------- | ------------------ | ---------------------------
              # **`id`**    | `integer`          | `not null, primary key`
              # **`name`**  | `string(50)`       | `not null`
              #
              # ### Indexes
              #
              # * `index_rails_02e851e3b7`:
              #     * **`id`**
              # * `index_rails_02e851e3b8` (_unique_):
              #     * **`foreign_thing_id`**
              #
            EOS
          end

          it "returns schema info with index information in Markdown format" do
            is_expected.to eq expected_result
          end
        end

        context 'when one of indexes includes "unique" clause with "not null distinct"' do
          let :indexes do
            [
              mock_index("index_rails_02e851e3b7", columns: ["id"]),
              mock_index("index_rails_02e851e3b8",
                columns: ["foreign_thing_id"],
                unique: true,
                nulls_not_distinct: true)
            ]
          end

          let :expected_result do
            <<~EOS
              # ## Schema Information
              #
              # Table name: `users`
              #
              # ### Columns
              #
              # Name        | Type               | Attributes
              # ----------- | ------------------ | ---------------------------
              # **`id`**    | `integer`          | `not null, primary key`
              # **`name`**  | `string(50)`       | `not null`
              #
              # ### Indexes
              #
              # * `index_rails_02e851e3b7`:
              #     * **`id`**
              # * `index_rails_02e851e3b8` (_unique_ _nulls_not_distinct_):
              #     * **`foreign_thing_id`**
              #
            EOS
          end

          it "returns schema info with index information in Markdown format" do
            is_expected.to eq expected_result
          end
        end

        context "when one of indexes includes ordered index key" do
          let :indexes do
            [
              mock_index("index_rails_02e851e3b7", columns: ["id"]),
              mock_index("index_rails_02e851e3b8",
                columns: ["foreign_thing_id"],
                orders: {"foreign_thing_id" => :desc})
            ]
          end

          let :expected_result do
            <<~EOS
              # ## Schema Information
              #
              # Table name: `users`
              #
              # ### Columns
              #
              # Name        | Type               | Attributes
              # ----------- | ------------------ | ---------------------------
              # **`id`**    | `integer`          | `not null, primary key`
              # **`name`**  | `string(50)`       | `not null`
              #
              # ### Indexes
              #
              # * `index_rails_02e851e3b7`:
              #     * **`id`**
              # * `index_rails_02e851e3b8`:
              #     * **`foreign_thing_id DESC`**
              #
            EOS
          end

          it "returns schema info with index information in Markdown format" do
            is_expected.to eq expected_result
          end
        end

        context 'when one of indexes includes "where" clause and "unique" clause' do
          let :indexes do
            [
              mock_index("index_rails_02e851e3b7", columns: ["id"]),
              mock_index("index_rails_02e851e3b8",
                columns: ["foreign_thing_id"],
                unique: true,
                where: "name IS NOT NULL")
            ]
          end

          let :expected_result do
            <<~EOS
              # ## Schema Information
              #
              # Table name: `users`
              #
              # ### Columns
              #
              # Name        | Type               | Attributes
              # ----------- | ------------------ | ---------------------------
              # **`id`**    | `integer`          | `not null, primary key`
              # **`name`**  | `string(50)`       | `not null`
              #
              # ### Indexes
              #
              # * `index_rails_02e851e3b7`:
              #     * **`id`**
              # * `index_rails_02e851e3b8` (_unique_ _where_ name IS NOT NULL):
              #     * **`foreign_thing_id`**
              #
            EOS
          end

          it "returns schema info with index information in Markdown format" do
            is_expected.to eq expected_result
          end
        end

        context 'when one of indexes includes "using" clause other than "btree"' do
          let :indexes do
            [
              mock_index("index_rails_02e851e3b7", columns: ["id"]),
              mock_index("index_rails_02e851e3b8",
                columns: ["foreign_thing_id"],
                using: "hash")
            ]
          end

          let :expected_result do
            <<~EOS
              # ## Schema Information
              #
              # Table name: `users`
              #
              # ### Columns
              #
              # Name        | Type               | Attributes
              # ----------- | ------------------ | ---------------------------
              # **`id`**    | `integer`          | `not null, primary key`
              # **`name`**  | `string(50)`       | `not null`
              #
              # ### Indexes
              #
              # * `index_rails_02e851e3b7`:
              #     * **`id`**
              # * `index_rails_02e851e3b8` (_using_ hash):
              #     * **`foreign_thing_id`**
              #
            EOS
          end

          it "returns schema info with index information in Markdown format" do
            is_expected.to eq expected_result
          end
        end
      end

      context 'when option "show_foreign_keys" is true' do
        let :primary_key do
          :id
        end

        let :options do
          AnnotateRb::Options.new({format_markdown: true, show_foreign_keys: true})
        end

        let :columns do
          [
            mock_column("id", :integer),
            mock_column("foreign_thing_id", :integer)
          ]
        end

        context 'when foreign_keys have option "on_delete" and "on_update"' do
          let :foreign_keys do
            [
              mock_foreign_key("fk_rails_02e851e3b7",
                "foreign_thing_id",
                "foreign_things",
                "id",
                on_delete: "on_delete_value",
                on_update: "on_update_value")
            ]
          end

          let :expected_result do
            <<~EOS
              # ## Schema Information
              #
              # Table name: `users`
              #
              # ### Columns
              #
              # Name                    | Type               | Attributes
              # ----------------------- | ------------------ | ---------------------------
              # **`id`**                | `integer`          | `not null, primary key`
              # **`foreign_thing_id`**  | `integer`          | `not null`
              #
              # ### Foreign Keys
              #
              # * `fk_rails_...` (_ON DELETE => on_delete_value ON UPDATE => on_update_value_):
              #     * **`foreign_thing_id => foreign_things.id`**
              #
            EOS
          end

          it "returns schema info with foreign_keys in Markdown format" do
            is_expected.to eq(expected_result)
          end
        end
      end
    end

    context 'when "format_doc" and "with_comment" are specified in options' do
      let :primary_key do
        :id
      end

      let :options do
        AnnotateRb::Options.new({format_rdoc: true, with_comment: true, with_column_comments: true})
      end

      let :columns do
        [
          mock_column("id", :integer),
          mock_column("name", :string, limit: 50)
        ]
      end

      context "when columns are normal" do
        let :columns do
          [
            mock_column("id", :integer, comment: "ID"),
            mock_column("name", :string, limit: 50, comment: "Name")
          ]
        end

        let :expected_result do
          <<~EOS
            # == Schema Information
            #
            # Table name: users
            #
            # *id(ID)*::     <tt>integer, not null, primary key</tt>
            # *name(Name)*:: <tt>string(50), not null</tt>
            #--
            # == Schema Information End
            #++
          EOS
        end

        it "returns schema info in RDoc format" do
          is_expected.to eq expected_result
        end
      end
    end

    context 'when "format_markdown" and "with_comment" are specified in options' do
      let :primary_key do
        :id
      end

      let :options do
        AnnotateRb::Options.new({format_markdown: true, with_comment: true, with_column_comments: true})
      end

      let :columns do
        [
          mock_column("id", :integer),
          mock_column("name", :string, limit: 50)
        ]
      end

      context "when columns have comments" do
        let :columns do
          [
            mock_column("id", :integer, comment: "ID"),
            mock_column("name", :string, limit: 50, comment: "Name")
          ]
        end

        let :expected_result do
          <<~EOS
            # ## Schema Information
            #
            # Table name: `users`
            #
            # ### Columns
            #
            # Name              | Type               | Attributes
            # ----------------- | ------------------ | ---------------------------
            # **`id(ID)`**      | `integer`          | `not null, primary key`
            # **`name(Name)`**  | `string(50)`       | `not null`
            #
          EOS
        end

        it "returns schema info in Markdown format" do
          is_expected.to eq expected_result
        end
      end

      context "when columns have multibyte comments" do
        let :columns do
          [
            mock_column("id", :integer, comment: "ＩＤ"),
            mock_column("name", :string, limit: 50, comment: "ＮＡＭＥ")
          ]
        end

        let :expected_result do
          <<~EOS
            # ## Schema Information
            #
            # Table name: `users`
            #
            # ### Columns
            #
            # Name                  | Type               | Attributes
            # --------------------- | ------------------ | ---------------------------
            # **`id(ＩＤ)`**        | `integer`          | `not null, primary key`
            # **`name(ＮＡＭＥ)`**  | `string(50)`       | `not null`
            #
          EOS
        end

        it "returns schema info in Markdown format" do
          is_expected.to eq expected_result
        end
      end
    end
  end
end
