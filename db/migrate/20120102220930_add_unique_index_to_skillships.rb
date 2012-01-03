class AddUniqueIndexToSkillships < ActiveRecord::Migration
  def self.up
    add_index :skillships, [:membership_id, :skill_id], :unique => true, :name => "index_skillships_on_membership_id_and_skill_id"
  end

  def self.down
    remove_index :skillships, :name => "index_skillships_on_membership_id_and_skill_id"
  end
end
