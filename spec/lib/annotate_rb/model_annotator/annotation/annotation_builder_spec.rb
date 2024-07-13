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

    context "happy path" do
      let :primary_key do
        :id
      end

      let :options do
        AnnotateRb::Options.new({
          show_indexes: true
        })
      end

      let :columns do
        [
          mock_column("id", :integer),
          mock_column("foreign_thing_id", :integer)
        ]
      end

      let :indexes do
        [
          mock_index("index_rails_02e851e3b7", columns: ["id"]),
          mock_index("index_rails_02e851e3b8", columns: ["foreign_thing_id"])
        ]
      end

      let :expected_result do
        <<~EOS
          # == Schema Information
          #
          # Table name: users
          #
          #  id               :integer          not null, primary key
          #  foreign_thing_id :integer          not null
          #
          # Indexes
          #
          #  index_rails_02e851e3b7  (id)
          #  index_rails_02e851e3b8  (foreign_thing_id)
          #
        EOS
      end

      it "returns schema info with index information" do
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
    end

    context "when columns have multibyte comments" do
      let :primary_key do
        :id
      end

      let :options do
        AnnotateRb::Options.new({classified_sort: false, with_comment: true, with_column_comments: true})
      end

      let :columns do
        [
          mock_column("id", :integer, limit: 8, comment: "ＩＤ"),
          mock_column("active", :boolean, limit: 1, comment: "ＡＣＴＩＶＥ"),
          mock_column("name", :string, limit: 50, comment: "ＮＡＭＥ"),
          mock_column("notes", :text, limit: 55, comment: "ＮＯＴＥＳ"),
          mock_column("cyrillic", :text, limit: 30, comment: "Кириллица"),
          mock_column("japanese", :text, limit: 60, comment: "熊本大学　イタリア　宝島"),
          mock_column("arabic", :text, limit: 20, comment: "لغة"),
          mock_column("no_comment", :text, limit: 20, comment: nil),
          mock_column("location", :geometry_collection, limit: nil, comment: nil)
        ]
      end

      let :expected_result do
        <<~EOS
          # == Schema Information
          #
          # Table name: users
          #
          #  id(ＩＤ)                           :integer          not null, primary key
          #  active(ＡＣＴＩＶＥ)               :boolean          not null
          #  name(ＮＡＭＥ)                     :string(50)       not null
          #  notes(ＮＯＴＥＳ)                  :text(55)         not null
          #  cyrillic(Кириллица)                :text(30)         not null
          #  japanese(熊本大学　イタリア　宝島) :text(60)         not null
          #  arabic(لغة)                        :text(20)         not null
          #  no_comment                         :text(20)         not null
          #  location                           :geometry_collect not null
          #
        EOS
      end

      it 'works with option "with_comment"' do
        is_expected.to eq expected_result
      end
    end

    context "when columns have multiline comments" do
      let :primary_key do
        :id
      end

      let :options do
        AnnotateRb::Options.new({classified_sort: false, with_comment: true, with_column_comments: true})
      end

      let :columns do
        [
          mock_column("id", :integer, limit: 8, comment: "ID"),
          mock_column("notes", :text, limit: 55, comment: "Notes.\nMay include things like notes."),
          mock_column("no_comment", :text, limit: 20, comment: nil)
        ]
      end

      let :expected_result do
        <<~EOS
          # == Schema Information
          #
          # Table name: users
          #
          #  id(ID)                                       :integer          not null, primary key
          #  notes(Notes.\\nMay include things like notes.):text(55)         not null
          #  no_comment                                   :text(20)         not null
          #
        EOS
      end

      it 'works with option "with_comment"' do
        is_expected.to eq expected_result
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

    context 'when "show_check_constraints" is true' do
      let :klass do
        mock_class_with_custom_connection(:users, primary_key, columns, custom_connection)
      end

      let :custom_connection do
        check_constraints = [
          mock_check_constraint("must_be_us_adult", "age >= 18")
        ]

        mock_connection([], [], check_constraints)
      end

      let :primary_key do
        :id
      end

      let :options do
        AnnotateRb::Options.new({show_check_constraints: true})
      end

      let :columns do
        [
          mock_column("id", :integer),
          mock_column("age", :integer)
        ]
      end

      let :expected_result do
        <<~EOS
          # == Schema Information
          #
          # Table name: users
          #
          #  id  :integer          not null, primary key
          #  age :integer          not null
          #
          # Check Constraints
          #
          #  must_be_us_adult  (age >= 18)
          #
        EOS
      end

      it "returns schema info with check constraints" do
        is_expected.to eq expected_result
      end
    end
  end
end
