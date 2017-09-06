module DispatchSteps
  class StampSubmissionMaterialsStep

    attr_reader :material_ids, :stamp_id

    def initialize(material_ids, stamp_id)
      @material_ids = material_ids
      @stamp_id     = stamp_id
    end

    # Apply Stamp to the materials
    def up
      begin
        stamp.apply_to(material_ids)
      rescue JsonApiClient::Errors::AccessDenied
        raise 'You cannot set a stamp of permissions to the materials because you do not have the ownership of the materials you want to claim'
      end
    end

    # Unapply Stamp to the materials
    def down
      stamp.unapply_to(material_ids)
    end

  private

    def stamp
      @stamp ||= StampClient::Stamp.find(stamp_id).first
    end

  end
end