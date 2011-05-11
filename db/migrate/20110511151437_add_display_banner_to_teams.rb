class AddDisplayBannerToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :display_banner, :boolean, :default => false
  end

  def self.down
    remove_column :teams, :display_banner
  end
end
