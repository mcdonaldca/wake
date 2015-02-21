class AddSleepWatchToUser < ActiveRecord::Migration
  def change
  	add_column :users, :sleep_watch, :integer
  end
end
