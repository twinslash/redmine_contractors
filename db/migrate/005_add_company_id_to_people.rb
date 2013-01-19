class AddCompanyIdToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :company_id, :integer
    remove_column :people, :company
  end

  def self.down
    remove_column :people, :company_id
    add_column :people, :company, :string
  end
end
