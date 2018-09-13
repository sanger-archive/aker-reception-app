class Printer < ApplicationRecord
  include Printables::Group

  validates :name, presence: true, uniqueness: true
  validates :label_type, presence: true

  before_validation :sanitise_name
  before_save :sanitise_name

  def self.PLATE_TEMPLATE
    "aker_code128_96plate"
  end
  def self.TUBE_TEMPLATE
    "aker_code128_1dtube"
  end

  def print_manifests(manifests)
    return true if Rails.configuration.printing_disabled
    print_printables(manifests.flat_map { |manifest| manifest_to_printables(manifest) })
  end

  def print_printables(printables)
    if label_type=='Plate'
      print_plates(name, Printer.PLATE_TEMPLATE, printables)
    else
      print_tubes(name, Printer.TUBE_TEMPLATE, printables)
    end
  end

  def printer_description
    "#{name} (#{label_type})"
  end

  def sanitise_name
    if name
      sanitised = name.strip.gsub(/\s+/, ' ')
      if sanitised != name
        self.name = sanitised
      end
    end
  end

private
  def manifest_to_printables(manifest)
    manifest.labwares.map.with_index(1) do |lw,i|
      {
        barcode: lw.barcode,
        sanger_human_barcode: lw.barcode,
        date: Date.today.to_s,
        collaborator_email: manifest.owner_email,
        sub_id: manifest.id,
        number: i,
        total_number: manifest.labwares.length,
        num_prints: lw.print_count+1,
      }
    end
  end
end
