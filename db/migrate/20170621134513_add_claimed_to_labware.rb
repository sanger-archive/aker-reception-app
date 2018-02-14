class AddClaimedToLabware < ActiveRecord::Migration[5.0]
  def change
    add_column :labwares, :claimed, :timestamp

    MaterialSubmission.where(status: 'claimed').flat_map(&:labwares).each do |lw|
      lw.update_attributes(claimed: DateTime.now)
    end
    MaterialSubmission.where(status: ['awaiting receipt', 'claimed']).update_all(status: MaterialSubmission.PRINTED)
  end
end
