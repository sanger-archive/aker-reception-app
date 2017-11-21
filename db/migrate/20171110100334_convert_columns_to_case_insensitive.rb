class ConvertColumnsToCaseInsensitive < ActiveRecord::Migration[5.0]
  def up
    enable_extension 'citext'

    change_column :contact_groups, :name, :citext
    change_column :contacts, :fullname, :citext, null: false
    change_column :contacts, :email, :citext, null: false
    change_column :labware_types, :name, :citext, null: false
    change_column :material_submissions, :owner_email, :citext
    change_column :printers, :name, :citext, null: false

    add_index :contacts, :email, unique: true

    ContactGroup.find_each { |g| g.save! if g.sanitise_name }
    Contact.find_each { |c| c.save! if [c.sanitise_fullname, c.sanitise_email].any? } # Non-short-circuiting OR
    LabwareType.find_each { |lt| lt.save! if lt.sanitise_name }
    MaterialSubmission.where.not(owner_email: nil).find_each { |s| s.save! if s.sanitise_owner }
    Printer.find_each { |p| p.save! if p.sanitise_name }
  end

  def down
    remove_index :contacts, :email

    change_column :contact_groups, :name, :string
    change_column :contacts, :fullname, :string, null: true
    change_column :contacts, :email, :string, null: true
    change_column :labware_types, :name, :string, null: true
    change_column :material_submissions, :owner_email, :string
    change_column :printers, :name, :string, null: true
  end
end
