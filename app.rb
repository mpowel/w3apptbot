require 'json'
require "sinatra"
require 'active_support/all'
require "active_support/core_ext"
require 'sinatra/activerecord'
require 'rake'

require 'twilio-ruby'
require 'stock_quote'

# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)
configure :development do
  require 'dotenv'
  Dotenv.load
end


# require models 
require_relative './models/user'
require_relative './models/log'
require_relative './models/track'

# enable sessions for this project

enable :sessions

# First you'll need to visit Twillio and create an account 
# you'll need to know 
# 1) your phone number 
# 2) your Account SID (on the console home page)
# 3) your Account Auth Token (on the console home page)
# then add these to the .env file 
# and use 
#   heroku config:set TWILIO_ACCOUNT_SID=XXXXX 
# for each environment variable

client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]


get '/incoming_sms' do

  session["last_context"] ||= nil
  
  sender = params[:From] || ""
  body = params[:Body] || ""
  body = body.downcase.strip
  
  if check_user_exists( sender )  
    
    user = get_user sender 
    #proceed
    if session["last_context"] == "begin_registration"
      user.name = body 
      user.save!
      session["last_context"] = "confirm_tandc"
      
      twiml = Twilio::TwiML::Response.new do |r|
        r.Message "Thanks #{user.first_name}. Just to check, you agree to the terms and conditions and will be ok to get one SMS notification daily?"
      end
      twiml.text

    elsif session["last_context"] == "confirm_tandc" and  body.include? "yes"
      user.agreed_to_terms = true 
      user.save!
      session["last_context"] = "onboard"
      
      twiml = Twilio::TwiML::Response.new do |r|
        r.Message "Great #{user.first_name}. To get started, just say 'hi', 'hello', 'about' or 'help'"
      end
      twiml.text

    elsif session["last_context"] == "confirm_tandc" and body.include? "no"
      user.agreed_to_terms = false 
      user.save!
      session["last_context"] = "confirm_tandc"
      
      twiml = Twilio::TwiML::Response.new do |r|
        r.Message "We're at an impass. I need you to confirm that if we're going to chat more"
      end
      twiml.text

    elsif user.agreed_to_terms and ['hi', 'hello', 'howdy'].include? body
      message = get_about_message
      
      twiml = Twilio::TwiML::Response.new do |r|
        r.Message message
      end
      twiml.text

    elsif user.agreed_to_terms and ['help'].include? body
      message = get_help_message

      twiml = Twilio::TwiML::Response.new do |r|
        r.Message message
      end
      twiml.text
      
    elsif !user.agreed_to_terms 
      message = get_help_message
      session["last_context"] = "confirm_tandc"

      twiml = Twilio::TwiML::Response.new do |r|
        r.Message "Please confirm the terms and conditions to proceed. Respond with YES or NO"
      end
      twiml.text   
      
    elsif body.starts_with? "lookup"
      
      stock_code = body.gsub! 'lookup', ''
      stock_code = stock_code.strip!
      
      stock = StockQuote::Stock.quote( stock_code )

      message = "#{stock.name} (#{stock.symbol}) is at #{stock.ask}. Change: #{stock.change_percent_change}."

      twiml = Twilio::TwiML::Response.new do |r|
        r.Message message
      end
      twiml.text   
      
    elsif body.starts_with? "tracking"
      
      if user.tracks.count > 0
        message = "Currently tracking: \n"
        user.tracks.each do |t|
          message += "#{t.name} (#{t.symbol})"
        end
      else
        message = "You're not tracking anything yet. Type 'track APPL' to add your first"
      end
      twiml = Twilio::TwiML::Response.new do |r|
        r.Message message
      end
      twiml.text   
      
    elsif body.starts_with? "track"
      
      stock_code = body.gsub! 'track', ''
      stock_code = stock_code.strip!

      stock = StockQuote::Stock.quote( stock_code )

      unless stock.nil? or stock.symbol.blank?
        
        # probably want to check it hasn't already been added here.

        Track.create( symbol: stock.symbol, name: stock.name, user_id: user.id )

        message = "OK. I'll send you a daily notification at close for #{stock.symbol}. \n"
        message += "You're now tracking #{ user.tracks.size + 1 } stocks"
      else
        message = "Doesn't look like '#{stock_code.upcase}' is a valid symbol!"
      end
      
      twiml = Twilio::TwiML::Response.new do |r|
        r.Message message
      end
      twiml.text   
            
    else    
      
      message = error_response
      session["last_context"] = "error"

      twiml = Twilio::TwiML::Response.new do |r|
        r.Message message
      end
      twiml.text   

    end 
    
  else 
    
    # the user isn't registered
    
    if session["last_context"] == "ask_for_registration" and body.include? "yes"
      begin_registration sender 
    elsif session["last_context"] == "ask_for_registration" and body.include? "no"
      error_out
    else 
      ask_for_registration
    end
  end
  
end 

private 

  def check_user_exists from_number
    User.where( phone_number: from_number ).count > 0
  end

  def get_user from_number
    User.where( phone_number: from_number ).first
  end

  def ask_for_registration
  
    session["last_context"] = "ask_for_registration"
  
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message "It doesn't look like you're registered. Would you like to get set up now?"
    end
    twiml.text
  
  end

  def begin_registration sender
  
    session["last_context"] = "begin_registration"
  
    user = User.create( phone_number: sender )
  
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message "Great. I'll get you set up. First, what's your name?"
    end
    twiml.text
  
  end 

  def error_out 
  
    session["last_context"] = "no registration"
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message "We're at an impass. I need you to register if we're going to chat more"
    end
    twiml.text 
  
  end 


  GREETINGS = ["Hi","Yo", "Hey","Howdy", "Hello", "Ahoy", "‘Ello", "Aloha", "Hola", "Bonjour", "Hallo", "Ciao", "Konnichiwa"]

  COMMANDS = "lookup APPL \n tracking \n track APPL \n help."

  def get_commands
    error_prompt = ["I know how to: ", "You can say: ", "Try asking: "].sample
  
    return error_prompt + COMMANDS
  end

  def get_greeting
    return GREETINGS.sample
  end

  def get_about_message
    get_greeting + ", I\'m StockBot 🤖. " + get_commands
  end

  def get_help_message
    "You're stuck, eh? " + get_commands
  end

  def error_response
    error_prompt = ["I didn't catch that.", "Hmmm I don't know that word.", "What did you say to me? "].sample
    error_prompt + " " + get_commands
  end

