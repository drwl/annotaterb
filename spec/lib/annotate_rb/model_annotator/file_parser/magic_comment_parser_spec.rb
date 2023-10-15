# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::FileParser::MagicCommentParser do
  describe ".call" do
    subject { described_class.call(content) }

    context "model file without any magic comments" do
      let(:content) do
        <<~FILE
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to be_blank }
    end

    context "model file with a normal comment" do
      let(:content) do
        <<~FILE
          # some comment describing the class
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to be_blank }
    end

    context "model file with '# encoding: UTF-8' magic comment" do
      let(:magic_comment) { "# encoding: UTF-8" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end

    context "model file with '# coding: UTF-8' magic comment" do
      let(:magic_comment) { "# coding: UTF-8" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end

    context "model file with '# -*- coding: UTF-8 -*-' magic comment" do
      let(:magic_comment) { "# -*- coding: UTF-8 -*-" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end

    context "model file with '#encoding: utf-8' magic comment" do
      let(:magic_comment) { "#encoding: utf-8" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end

    context "model file with '# encoding: utf-8' magic comment" do
      let(:magic_comment) { "# encoding: utf-8" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end

    context "model file with '# -*- encoding : utf-8 -*-' magic comment" do
      let(:magic_comment) { "# -*- encoding : utf-8 -*-" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end

    context "model file with \"# encoding: utf-8\n# frozen_string_literal: true\" magic comment" do
      let(:magic_comment) { "# encoding: utf-8\n# frozen_string_literal: true" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end

    context "model file with \"# frozen_string_literal: true\n# encoding: utf-8\" magic comment" do
      let(:magic_comment) { "# frozen_string_literal: true\n# encoding: utf-8" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end

    context "model file with '# frozen_string_literal: true' magic comment" do
      let(:magic_comment) { "# frozen_string_literal: true" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end

    context "model file with '#frozen_string_literal: false' magic comment" do
      let(:magic_comment) { "#frozen_string_literal: false" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end

    context "model file with '# -*- frozen_string_literal : true -*-' magic comment" do
      let(:magic_comment) { "# -*- frozen_string_literal : true -*-" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end

    context "model file with '# typed: ignore' magic comment" do
      let(:magic_comment) { "# typed: ignore" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end

    context "model file with '# typed: false' magic comment" do
      let(:magic_comment) { "# typed: false" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end

    context "model file with '# typed: true' magic comment" do
      let(:magic_comment) { "# typed: true" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end

    context "model file with '# typed: strict' magic comment" do
      let(:magic_comment) { "# typed: strict" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end

    context "model file with '# typed: strong' magic comment" do
      let(:magic_comment) { "# typed: strong" }
      let(:expected) { "#{magic_comment}\n" }
      let(:content) do
        <<~FILE
          #{magic_comment}
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to eq(expected) }
    end
  end
end
