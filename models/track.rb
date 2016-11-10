class Track < ActiveRecord::Base
  
  validates_presence_of :symbol, message: "Symbol cannot be blank."
  
  belongs_to :user

  
  
end