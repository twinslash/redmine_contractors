class AddDefaultRoleToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :default_role_id, :string
  end

  def self.down
    remove_column :people, :default_role_id
  end
end
