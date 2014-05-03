require 'spec_helper'

describe Shapter::PingV1 do 
  it "ping" do 
    get "/ping", {}, {"Accept-Version" => 'v1'}
    response.body.should == { ping: :pong, :version => 'v1'}.to_json
  end

  it "ping with parameters" do 
    get "/ping", {:ping => :lol}, {"Accept-Version" => 'v1'}
    response.body.should == { ping: :lol, :version => 'v1'}.to_json
  end
end
