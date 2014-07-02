require 'spec_helper'

describe Shapter::V7::Ping do 

  it "ping" do 
    get "/ping", {}, {"Accept-Version" => 'v7'}
    response.body.should == { ping: :pong, :version => 'v7'}.to_json
  end

  it "ping with parameters" do 
    get "/ping", {:ping => :lol}, {"Accept-Version" => 'v7'}
    response.body.should == { ping: :lol, :version => 'v7'}.to_json
  end
end

