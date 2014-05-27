require 'spec_helper'

describe Shapter::V4::Ping do 

  it "ping" do 
    get "/ping", {}, {"Accept-Version" => 'v3'}
    response.body.should == { ping: :pong, :version => 'v3'}.to_json
  end

  it "ping with parameters" do 
    get "/ping", {:ping => :lol}, {"Accept-Version" => 'v3'}
    response.body.should == { ping: :lol, :version => 'v3'}.to_json
  end
end

