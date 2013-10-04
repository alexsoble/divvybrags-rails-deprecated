class CreateTips < ActiveRecord::Migration
  def change
    create_table :tips do |t|
      t.string :img_url
      t.string :name

      t.timestamps
    end
  end
end
