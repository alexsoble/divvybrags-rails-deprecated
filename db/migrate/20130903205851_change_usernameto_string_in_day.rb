class ChangeUsernametoStringInDay < ActiveRecord::Migration
  def change
    change_column :days, :username, :string
  end
end
