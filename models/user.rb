class User < ActiveRecord::Base
  
  validates_presence_of :phone_number, message: "Phone number cannot be blank."
  
  has_many :logs
  has_many :tracks
  
  def first_name
    return "" if name.blank?
    if name.split.count > 1
       name.split.first
     else
       name
     end
  end

  def last_name
    return "" if name.blank?
    if name.split.count > 1
      name.split[1..-1].join(' ')
    else
      ""
    end
  end
  
  
end