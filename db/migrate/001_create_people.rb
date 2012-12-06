class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.integer :user_id
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :email
      t.string :company
      t.string :job_title
      t.string :avatar
      t.string :nickname
      t.string :gender
      t.date :birthday
      t.string :address
      t.string :mobile_phone
      t.string :landline_phone
      t.string :skype
      t.string :github
      t.string :facebook
      t.string :twitter
      t.string :linkedin
      t.string :foursquare
      t.text :background
    end

  end
end
