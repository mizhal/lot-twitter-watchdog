require 'spec_helper'
require 'logger'

require 'mocks/twitter_raw_protocol_mock'

RSpec::Expectations.configuration.warn_about_potential_false_positives = false

describe Lot::TwitterWatchdog::TwitterTouchGraphGenerator do
  it "scans touches" do
    LOG_FILE = "touch.log"
    FileUtils.rm_f LOG_FILE

    catalog = TwitterRawProtocolMock.catalog

    names = ["gem", "TweetDeck", "CayenneIoT", "UI_daily", "CollectUI", "DailyUI", "123xxxunharvastable"]
    names.each do |name|
      catalog.TwitterTarget.create(screen_name: name)
    end

    control = Lot::TwitterWatchdog::TwitterControl.new "spec/lot/twitter-api.yml", "test"
    expect(control.smoke_test).to be(true), "twitter api client not connected or failed"

    harv = Lot::TwitterWatchdog::TwitterTouchGraphGenerator.new catalog, control.client  
    harv.logger = Logger.new LOG_FILE
    harv.execute do
      sleep Lot::TwitterWatchdog::SLEEP_TIME
    end
    
    logstr = nil
    expect{ logstr = File.new(LOG_FILE).read }.to_not raise_error
    expect(logstr.lines.count).to be >= 1

    catalog.TwitterTarget.destroy_all
    catalog.TwitterTouch.destroy_all
  end 
end