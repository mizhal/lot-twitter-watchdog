require 'spec_helper'
require 'mocks/twitter_raw_protocol_mock'

RSpec::Expectations.configuration.warn_about_potential_false_positives = false

LINK_LIMIT = 5

describe Lot::TwitterWatchdog::TwitterGraphGenerator do
  it "creates a local graph for a simple seed" do

    catalog = TwitterRawProtocolMock.catalog
    expect(catalog.TwitterLink).to be TwitterLinkMock 
    ## check interface required for component
    expect{  catalog.TwitterLink.method(:find_by)  }.to_not raise_error(NameError) 
    expect{  catalog.TwitterLink.method(:create)  }.to_not raise_error(NameError) 
    expect{  catalog.TwitterTarget.method(:all)  }.to_not raise_error(NameError)
    expect{  catalog.TwitterTarget.method(:destroy_all)  }.to_not raise_error(NameError)
    catalog.TwitterLink.create(screen_name1: "gem", screen_name2: "muxi")
    catalog.TwitterLink.create(screen_name1: "gem", screen_name2: "gfem2")
    expect(catalog.TwitterLink.find_by(screen_name1: "gem", screen_name2: "muxi").count).to be 1
    catalog.TwitterLink.destroy_all
    ## FIN: check interface required for component

    catalog.TwitterTarget.create(screen_name: "gem")
    
    control = Lot::TwitterWatchdog::TwitterControl.new "spec/lot/twitter-api.yml", "test"
    expect(control.smoke_test).to be(true), "twitter api client not connected or failed"

    gen = Lot::TwitterWatchdog::TwitterGraphGenerator.new control.client, catalog, LINK_LIMIT
    
    gen.execute do
      sleep Lot::TwitterWatchdog::SLEEP_TIME
    end

    ## LINK_LIMIT gets counted twice, for followers and following
    expect(catalog.TwitterLink.count).to be(LINK_LIMIT * 2)#, "followers and following count doesnt match"

    catalog.TwitterTarget.destroy_all
    catalog.TwitterLink.destroy_all    
  end
end