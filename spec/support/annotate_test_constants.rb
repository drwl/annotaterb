# frozen_string_literal: true

module AnnotateTestConstants
  MAGIC_COMMENTS = [
    "# encoding: UTF-8",
    "# coding: UTF-8",
    "# -*- coding: UTF-8 -*-",
    "#encoding: utf-8",
    "# encoding: utf-8",
    "# -*- encoding : utf-8 -*-",
    "# encoding: utf-8\n# frozen_string_literal: true",
    "# frozen_string_literal: true\n# encoding: utf-8",
    "# frozen_string_literal: true",
    "#frozen_string_literal: false",
    "# -*- frozen_string_literal : true -*-"
  ].freeze
end
