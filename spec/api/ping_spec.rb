require 'spec_helper'

describe Shapter::Ping do 
  it "ping" do 
    get "/ping"
    response.body.should == { ping: :pong}.to_json
  end

  it "ping with parameters" do 
    get "/ping", :ping => :lol
    response.body.should == { ping: :lol}.to_json
  end
end
