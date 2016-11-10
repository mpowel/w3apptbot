class CreateLogsForIncomingMessages < ActiveRecord::Migration
  def change
    
    create_table :logs do |t|
      
      t.string :from
      t.text :message
      t.text :response
      t.string :context
      t.integer :user_id
        
      t.timestamps
    end
  end
end
