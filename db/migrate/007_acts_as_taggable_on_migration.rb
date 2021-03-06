class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    unless table_exists?('tags')
      create_table :tags do |t|
        t.string :name
      end
    end

    unless table_exists?('taggings')
      create_table :taggings do |t|
        t.references :tag

        # You should make sure that the column created is
        # long enough to store the required class names.
        t.references :taggable, :polymorphic => true
        t.references :tagger, :polymorphic => true

        # Limit is created to prevent MySQL error on index
        # length for MyISAM table type: http://bit.ly/vgW2Ql
        t.string :context, :limit => 128

        t.datetime :created_at
      end

      add_index :taggings, :tag_id
      add_index :taggings, [:taggable_id, :taggable_type, :context]
    end
  end

  def self.down
    drop_table :taggings if table_exists?('taggings')
    drop_table :tags if table_exists?('tags')
  end

  def table_exists?(table)
    ActiveRecord::Base.connection.table_exists? table
  end
end