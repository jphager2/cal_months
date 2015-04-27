class CreateCalMonths < ActiveRecord::Migration
  def change
    create_table :cal_months do |t|
      t.integer :year
      t.integer :month
      t.text :event_data

      t.timestamps
    end
  end
end
