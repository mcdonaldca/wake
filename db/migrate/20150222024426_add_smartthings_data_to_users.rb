class AddSmartthingsDataToUsers < ActiveRecord::Migration
  def change
		add_column :users, :smartthings_access_token, :string
		add_column :users, :smartthings_api_endpoint, :string
  end
end
