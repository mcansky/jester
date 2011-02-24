class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :issue_id
      t.datetime :edited_at
      t.integer :cid
      t.string :user
      t.text :body
      t.string :hash

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
