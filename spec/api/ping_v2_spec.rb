require 'spec_helper'

describe Shapter::PingV2 do 

  it "ping" do 
    get "/ping", {}, {"Accept-Version" => 'v2'}
    response.body.should == { ping: :pong, :version => 'v2'}.to_json
  end

  it "ping with parameters" do 
    get "/ping", {:ping => :lol}, {"Accept-Version" => 'v2'}
    response.body.should == { ping: :lol, :version => 'v2'}.to_json
  end
end

