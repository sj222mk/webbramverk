class CreateApiKeys < ActiveRecord::Migration  
  def change
    create_table :api_keys do |t|
      t.string :access_token
      t.references :user, index: true, foreign_key: true
      t.string :description 
      t.datetime :expires_at

      t.timestamps null: false
    end

    add_index :api_keys, [:access_token], name: "index_api_keys_on_access_token", unique: true
    add_index :api_keys, [:created_at]
  end
end  