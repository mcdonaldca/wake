class AddInfoToUser < ActiveRecord::Migration
  def change
  	add_column :users, :directv_ip, :string
  	add_column :users, :aural, :integer
  	add_column :users, :pebble_loc, :string
  end
end
