class ChangeMilesToFloatInDay < ActiveRecord::Migration
  def change
    change_column :days, :miles, :float
  end
end
