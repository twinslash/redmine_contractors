class AddContactTypeToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :contact_type, :string
  end

  def self.down
    remove_column :people, :contact_type
  end
end
