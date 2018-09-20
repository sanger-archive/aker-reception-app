module DispatchSteps
  class CreateContainersStep
    def initialize(manifest)
      @manifest = manifest
    end

    def up
      @manifest.labwares.each do |lw|
        unless lw.container_id
          container = MatconClient::Container.create(
            num_of_rows: lw.num_of_rows,
            num_of_cols: lw.num_of_cols,
            row_is_alpha: lw.row_is_alpha,
            col_is_alpha: lw.col_is_alpha,
            print_count: 0,
            supplier_plate_name: lw.supplier_plate_name
          )
          lw.update_attributes(barcode: container.barcode, container_id: container.id)

          lw.contents.each do |address, bio_data|
            slot = container.slots.select { |s| s.address == address }.first
            slot.material_id = bio_data['id']
          end
          container.save
        end
      end
    end

    def down
      @manifest.labwares.each do |lw|
        if lw.container_id
          MatconClient::Container.destroy(lw.container_id)
          lw.update_attributes(barcode: nil, container_id: nil)
        end
      end
    end
  end
end