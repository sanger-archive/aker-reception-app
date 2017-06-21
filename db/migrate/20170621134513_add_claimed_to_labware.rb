class AddClaimedToLabware < ActiveRecord::Migration[5.0]
  def change
    add_column :labwares, :claimed, :timestamp
  end
end
