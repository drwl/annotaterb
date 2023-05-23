# monkey patches

# standard:disable Style/MissingRespondToMissing
module ::ActiveRecord
  class Base
    def self.method_missing(_name, *_args)
      # ignore this, so unknown/unloaded macros won't cause parsing to fail
    end
  end
end
# standard:enable Style/MissingRespondToMissing
