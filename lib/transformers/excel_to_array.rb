# Transformer to convert an Excel spreadsheet to a List of Hashes where each key is the column name,
# and each cell is the value
# e.g. [{ plate_id: 1, position: 'A:1', donor_id: '12345' }, { plate_id: 1, position: 'B:1', donor_id: '67890' }]
# If a CSV file is provided will parse that also
module Transformers
  class ExcelToArray < Base

    def transform
      begin
        @contents = to_array
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

    def to_csv
      CSV.parse(transformer.to_csv, headers: true, skip_blanks: true, header_converters: :symbol)
        .lazy
        .map {|row| row.to_h.inject({}) { |h, (k, v)| h[k] = v || ""; h } } # Convert nils to empty strings
        .reject { |row| row.values.all?(&:blank?) } # Remove any rows that have all blank values
        .force
    end

    def to_array
      parse_csv.reduce([]) do |arr, row|
        row = format_row(row)
        arr << row unless row.values.all?(&:blank?) # Filter out blank lines
        arr
      end
    end

    def parse_csv
      CSV.parse(transformer.to_csv, headers: true, skip_blanks: true, header_converters: :symbol)
    end

    # Doesn't add columns where the header is nil
    # Converts any nil values to empty strings
    def format_row(row)
      row.to_h.inject({}) do |row, (header, value)|
        row[header] = value || "" unless header.nil?
        row
      end
    end

  end
end