require 'spec_helper'
require 'logger'

require 'mocks/twitter_raw_protocol_mock'

describe TwitterRawProtocolMock do
  it "exports to csv" do
    catalog = TwitterRawProtocolMock.catalog

    names = ["gem", "TweetDeck", "CayenneIoT", "UI_daily", "CollectUI", "DailyUI", "123xxxunharvastable"]
    names.each do |name|
      catalog.TwitterTarget.create(screen_name: name)
    end

    catalog.TwitterTarget.export_to_csv "targets-inspected.csv"

    catalog.TwitterTarget.destroy_all
  end
end