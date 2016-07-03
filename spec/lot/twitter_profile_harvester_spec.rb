require 'spec_helper'
require 'mocks/twitter_raw_protocol_mock'

RSpec::Expectations.configuration.warn_about_potential_false_positives = false

LINK_LIMIT = 5

describe Lot::TwitterWatchdog::TwitterProfileHarvester do
  it "harvests profiles" do
    catalog = TwitterRawProtocolMock.catalog

    names = ["gem", "TweetDeck", "CayenneIoT", "UI_daily", "CollectUI", "DailyUI"]
    names.each do |name|
      catalog.TwitterTarget.create(screen_name: name)
    end

    control = Lot::TwitterWatchdog::TwitterControl.new "spec/lot/twitter-api.yml", "test"
    expect(control.smoke_test).to be(true), "twitter api client not connected or failed"

    harv = Lot::TwitterWatchdog::TwitterProfileHarvester.new catalog, control.client, LINK_LIMIT  
    harv.execute do
      sleep Lot::TwitterWatchdog::SLEEP_TIME
    end

    catalog.TwitterTarget.destroy_all
    catalog.TwitterRawProfile.destroy_all
    
  end
end