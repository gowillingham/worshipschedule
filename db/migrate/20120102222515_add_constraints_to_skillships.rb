class AddConstraintsToSkillships < ActiveRecord::Migration
  def self.up
    change_column :skillships, :membership_id, :integer, :null => false
    change_column :skillships, :skill_id, :integer, :null => false
  end

  def self.down
    change_column :skillships, :membership_id, :integer, :null => true
    change_column :skillships, :skill_id, :integer, :null => true
  end
end
