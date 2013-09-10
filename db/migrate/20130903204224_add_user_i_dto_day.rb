class AddUserIDtoDay < ActiveRecord::Migration
  def change
    add_column :days, :user_id, :integer
  end
end