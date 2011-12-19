class CreateSkills < ActiveRecord::Migration
  def self.up
    create_table :skills do |t|
      t.references :team, :null => false
      t.string :name, :null => false
      t.string :description
      t.timestamps
    end

    add_index :skills, :name
  end

  def self.down
    drop_table :skills
  end
end
