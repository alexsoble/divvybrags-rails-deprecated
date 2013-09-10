class CreateDays < ActiveRecord::Migration
  def change
    create_table :days do |t|
      t.date :this_date
      t.integer :miles

      t.timestamps
    end
  end
end
