class AddResumeFieldsToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :hire_date, :date
    add_column :people, :education, :string
    add_column :people, :education_info, :text
    add_column :people, :experience, :text
    add_column :people, :strengths_and_weaknesses, :text
  end

  def self.down
    remove_column :people, :hire_date
    remove_column :people, :education
    remove_column :people, :education_info
    remove_column :people, :experience
    remove_column :people, :strengths_and_weaknesses
  end
end
