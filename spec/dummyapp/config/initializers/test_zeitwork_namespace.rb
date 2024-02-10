# frozen_string_literal: true

Object.const_set(:Namespace, Module.new) unless Object.const_defined?(:Namespace)

Rails.autoloaders.main.push_dir(Rails.root.join("app/namespace/models"), namespace: Namespace)
