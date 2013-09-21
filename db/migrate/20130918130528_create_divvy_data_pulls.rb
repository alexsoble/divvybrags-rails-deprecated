class CreateDivvyDataPulls < ActiveRecord::Migration
  def change
    create_table :divvy_data_pulls do |t|

      t.timestamps
    end
  end
end
