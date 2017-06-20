require 'set'

module MaterialSubmissionsHelper

  def list_contents_keys(labwares)
    keys = Set.new()
    labwares.each do |labware|
      if labware.contents
        labware.contents.each do |address, bio_data|
          bio_data.each do |key, value|
            keys.add(key)
          end
        end
      end
    end
    return keys
  end
end
