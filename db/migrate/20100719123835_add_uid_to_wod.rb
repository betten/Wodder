class AddUidToWod < ActiveRecord::Migration
  def self.up
    add_column :wods, :uid, :string
  end

  def self.down
    remove_column :wods, :uid
  end
end
