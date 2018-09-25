# Transformer to convert an Excel spreadsheet to CSV
# If a CSV file is provided will parse that also
module Transformers
  class ExcelToCsv < Base

    def transform
      begin
        @contents = transformer.to_csv
        return true
      rescue Roo::FileNotFound, IOError
        errors.add(:base, 'File could not be found.')
      rescue TypeError
        errors.add(:base, 'File is not of the right type. Please provide an xlsx, xlsm, or csv file.')
      # Zip library is used for opening files by Roo
      rescue Zip::Error
        errors.add(:base, 'File can not be read. It may be corrupted, or not in the correct format.')
      rescue
        errors.add(:base, 'Something went wrong while reading the file. It may be corrupted, or not in the correct format.')
      end

      return false
    end

    private

    def transformer
      @transformer ||= path.extname == '.csv' ? Roo::CSV.new(path) : Roo::Excelx.new(path)
    end

  end
end