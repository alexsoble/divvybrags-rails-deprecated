class ChangeUserIDtoUsername < ActiveRecord::Migration
  def change
    rename_column :days, :user_id, :username
  end
end
