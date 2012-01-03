class CreateSkillships < ActiveRecord::Migration
  def self.up
    create_table :skillships do |t|
      t.integer :membership_id
      t.integer :skill_id
      t.timestamps
    end
  end

  def self.down
    drop_table :skillships
  end
end
