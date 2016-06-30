require 'spec_helper'
require 'mocks/twitter_raw_protocol_mock'

describe Lot::TwitterWatchdog::TwitterGraphGenerator do
  it "creates a local graph for a simple seed" do

    catalog = TwitterRawProtocolMock.catalog
    expect(catalog.TwitterLink).to be TwitterLinkMock 
    ## check interface required for component
    expect{  catalog.TwitterLink.method(:find_by)  }.to_not raise_error(NameError) 
    expect{  catalog.TwitterLink.method(:create)  }.to_not raise_error(NameError) 
    catalog.TwitterLink.create(screen_name1: "gem", screen_name2: "muxi")
    catalog.TwitterLink.create(screen_name1: "gem", screen_name2: "gfem2")
    expect(catalog.TwitterLink.find_by(screen_name1: "gem", screen_name2: "muxi").count).to be 1
    ## FIN: check interface required for component

    client = Lot::TwitterWatchdog::TwitterControl.new "spec/lot/twitter-api.yml", "test"
    expect(client.smoke_test).to be(true), "twitter api client not connected or failed"

    gen = Lot::TwitterWatchdog::TwitterGraphGenerator.new client, catalog
    
  end
end