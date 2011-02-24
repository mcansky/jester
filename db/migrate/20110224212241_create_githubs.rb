class CreateGithubs < ActiveRecord::Migration
  def self.up
    create_table :githubs do |t|
      t.string :organization
      t.string :token
      t.string :user

      t.timestamps
    end
  end

  def self.down
    drop_table :githubs
  end
end
