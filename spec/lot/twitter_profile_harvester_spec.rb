require 'spec_helper'
require 'logger'

require 'mocks/twitter_raw_protocol_mock'

RSpec::Expectations.configuration.warn_about_potential_false_positives = false

describe Lot::TwitterWatchdog::TwitterProfileHarvester do
  it "harvests profiles" do
    catalog = TwitterRawProtocolMock.catalog

    names = ["gem", "TweetDeck", "CayenneIoT", "UI_daily", "CollectUI", "DailyUI"]
    names.each do |name|
      catalog.TwitterTarget.create(screen_name: name)
    end

    control = Lot::TwitterWatchdog::TwitterControl.new "spec/lot/twitter-api.yml", "test"
    expect(control.smoke_test).to be(true), "twitter api client not connected or failed"

    harv = Lot::TwitterWatchdog::TwitterProfileHarvester.new catalog, control.client
    harv.execute do
      sleep Lot::TwitterWatchdog::SLEEP_TIME
    end

    catalog.TwitterTarget.destroy_all
    catalog.TwitterRawProfile.destroy_all
    
  end

  it "logs not found profiles" do
    LOG_FILE = "harvester.log"
    FileUtils.rm_f LOG_FILE

    catalog = TwitterRawProtocolMock.catalog

    names = ["gem", "TweetDeck", "CayenneIoT", "UI_daily", "CollectUI", "DailyUI", "123xxxunharvastable"]
    names.each do |name|
      catalog.TwitterTarget.create(screen_name: name)
    end

    control = Lot::TwitterWatchdog::TwitterControl.new "spec/lot/twitter-api.yml", "test"
    expect(control.smoke_test).to be(true), "twitter api client not connected or failed"

    harv = Lot::TwitterWatchdog::TwitterProfileHarvester.new catalog, control.client  
    harv.logger = Logger.new LOG_FILE
    harv.execute do
      sleep Lot::TwitterWatchdog::SLEEP_TIME
    end

    expect(catalog.TwitterRawProfile.count).to be(names.count), "the watcher has not created all inspected profiles in the database"
    expect(harv.not_found_count).to be(1), "An unexpected number of profiles failed to be gathered"

    logstr = nil
    expect{ logstr = File.new(LOG_FILE).read }.to_not raise_error
    expect(logstr.lines.count).to be >= 2  

    catalog.TwitterTarget.destroy_all
    catalog.TwitterRawProfile.destroy_all
  end 
end