class CreateCreators < ActiveRecord::Migration
  def change
    create_table :creators do |t|
      t.string :email, null: false, uniqueness: { case_sensitive: false }
      t.string :displayname, limit: 30, null: false
      t.string :password_digest, null: false
      
      t.timestamps null: false
    end
  end
end
