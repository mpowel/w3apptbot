class CreateTrackingTable < ActiveRecord::Migration[5.0]
  def change
    
    create_table :tracks do |t|
      
      t.string :symbol
      t.text :name
      t.integer :user_id
        
      t.timestamps
    end
    
  end
end
