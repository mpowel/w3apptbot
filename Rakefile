# require your app file first
require './app'
require 'sinatra/activerecord/rake'


desc "This task is called by the Heroku scheduler add-on"

task :send_daily_update do

  ActiveRecord::Base.connection
  client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]

  User.all.each do |u|
    
    message = "Daily update: \n"
    u.tracks.each do |t|
      stock = StockQuote::Stock.quote( t.symbol )
      message += "#{stock.name} (#{stock.symbol}) is at #{stock.ask}. Change: #{stock.change_percent_change}. \n"
    end
    
    client.account.messages.create(
      :from => ENV["TWILIO_FROM"],
      :to => u.phone_number,
      :body => message
    )
    
  end

end
