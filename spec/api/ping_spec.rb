require 'spec_helper'

describe Shapter::V6::Ping do 

  it "ping" do 
    get "/ping", {}, {"Accept-Version" => 'v5'}
    response.body.should == { ping: :pong, :version => 'v5'}.to_json
  end

  it "ping with parameters" do 
    get "/ping", {:ping => :lol}, {"Accept-Version" => 'v5'}
    response.body.should == { ping: :lol, :version => 'v5'}.to_json
  end
end

