module AnnotateRb
  class << self
    def version
      @version ||= File.read(File.expand_path('../../VERSION', __dir__)).strip
    end
  end
end

