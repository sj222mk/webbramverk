class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.belongs_to :creator, index: true
      t.belongs_to :location, index: true
      
      
      t.string :placetype, limit: 30, null: false
      t.string :placename, limit: 30, null: false
      t.integer :grade, null: false
      t.text :description, limit: 300, null: false
      
      t.references :location, foreign_key: true
      t.integer :creator, foreign_key: true

      t.timestamps null: false
    end
  end
end
