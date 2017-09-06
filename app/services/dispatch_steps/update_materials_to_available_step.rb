module DispatchSteps
  class UpdateMaterialsToAvailableStep

    attr_reader :material_ids

    def initialize(material_ids)
      @material_ids = material_ids
    end

    def up
      material_ids.each { |mid| MatconClient::Material.new(_id: mid).update_attributes(available: true) }
    end

    def down
      material_ids.each { |mid| MatconClient::Material.new(_id: mid).update_attributes(available: false) }
    end
  end
end