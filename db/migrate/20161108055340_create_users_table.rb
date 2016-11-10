class CreateUsersTable < ActiveRecord::Migration[5.0]
  def change
    
    create_table :users do |t|
      
      t.text :name

      t.string :phone_number
      t.string :email_address

      t.boolean :agreed_to_terms, default: false
      t.boolean :on_boarded, default: false
        
      t.timestamps
    end
    
  end
end
