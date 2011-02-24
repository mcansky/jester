class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.string :title
      t.string :user
      t.text :labels
      t.datetime :edited_at
      t.string :state
      t.integer :repository_id
      t.string :hash

      t.timestamps
    end
  end

  def self.down
    drop_table :issues
  end
end
