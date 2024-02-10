# frozen_string_literal: true

collapsed_example = "#{Rails.root}/app/models/collapsed/example"
Rails.autoloaders.main.collapse(collapsed_example)

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir(collapsed_example)
  end
end