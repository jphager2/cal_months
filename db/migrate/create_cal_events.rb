class CreateCalEvents < ActiveRecord::Migration
  def change
    create_table :cal_events do |t|
      t.string :name
      t.text :description
      t.text :rdate
      t.string :system_uid
      t.datetime :system_updated_at

      t.timestamps
    end
  end
end
