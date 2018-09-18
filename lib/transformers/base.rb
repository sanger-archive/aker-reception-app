# Transformers convert content from a file from form to another e.g. Excel Spreadsheet --> CSV
#
# It has one primary method: #transform, which performs the actual transformation
#
# If the transformation is successful, it returns true and the resulting data is put on the @contents instance
# variable (accessible using #contents)
#
# If the transformation is not successful, it returns false and validation errors will be available through #errors
# which uses ActiveModel::Errors
#

module Transformers
  class Base

    extend ActiveModel::Naming
    attr_reader :errors, :contents

    def initialize(options)
      @path = Pathname.new(options.fetch(:path))
      @errors = ActiveModel::Errors.new(self)
    end

    def transform
      raise NotImplementedError
    end

    private

    attr_reader :path
  end
end