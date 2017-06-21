class AddClaimedToLabware < ActiveRecord::Migration[5.0]
  def change
    add_column :labwares, :claimed, :timestamp

    claimed_submissions = MaterialSubmission.where(status: 'claimed')
    claimed_submissions.flat_map(&:labwares).each do |lw|
      lw.update_attributes(claimed: DateTime.now)
    end
    claimed_submissions.update_all(status: MaterialSubmission.AWAITING)
  end
end
