require 'spec_helper'
require 'logger'
require 'mocks/twitter_raw_protocol_mock'

LINK_LIMIT = 5

module Lot
  module TwitterWatchdog

    describe Lot::TwitterWatchdog do
      it 'has a version number' do
        expect(Lot::TwitterWatchdog::VERSION).not_to be nil
      end

      it 'can work with tasks' do
        tasks = []

        catalog = TwitterRawProtocolMock.catalog
        catalog.TwitterTarget.create(screen_name: "gem")

        control = Lot::TwitterWatchdog::TwitterControl.new "spec/lot/twitter-api.yml", "test"
        expect(control.smoke_test).to be(true), "twitter api client not connected or failed"

        gen = Lot::TwitterWatchdog::TwitterGraphGenerator.new control.client, catalog, LINK_LIMIT
        
        tasks << gen

        w = Watchdog.new tasks
        w.run

        ## LINK_LIMIT gets counted twice, for followers and following
        expect(catalog.TwitterLink.count).to be(LINK_LIMIT * 2), "followers and following count doesnt match"

        catalog.TwitterTarget.destroy_all
        catalog.TwitterLink.destroy_all  
      end

      it 'can run with gem initializer' do

        catalog = TwitterRawProtocolMock.catalog
        catalog.TwitterTarget.create(screen_name: "gem")

        Lot::TwitterWatchdog.configure do |config|
          config.api_secrets_file = "spec/lot/twitter-api.yml"
          config.environment = "test"
          config.logger = nil
          config.tasks = [
            Lot::TwitterWatchdog::TwitterGraphGenerator.new(nil, catalog, LINK_LIMIT)
          ]
        end

        expect(catalog.TwitterLink.count).to be(LINK_LIMIT * 2), "followers and following count doesnt match"

        catalog.TwitterTarget.destroy_all
        catalog.TwitterLink.destroy_all

      end

      it 'can run with gem initializer and logger' do

        LOG_FILE = "spec-test-initializer.log"

        FileUtils.rm_f LOG_FILE

        catalog = TwitterRawProtocolMock.catalog
        catalog.TwitterTarget.create(screen_name: "gem")

        Lot::TwitterWatchdog.configure do |config|
          config.api_secrets_file = "spec/lot/twitter-api.yml"
          config.environment = "test"
          config.logger = Logger.new(LOG_FILE)
          config.tasks = [
            Lot::TwitterWatchdog::TwitterGraphGenerator.new(nil, catalog, LINK_LIMIT)
          ]
        end

        logstr = nil
        expect{ logstr = File.new(LOG_FILE).read }.to_not raise_error
        expect(logstr.lines.count).to be >= 2 # header + message

        expect(catalog.TwitterLink.count).to be(LINK_LIMIT * 2), "followers and following count doesnt match"

        catalog.TwitterTarget.destroy_all
        catalog.TwitterLink.destroy_all

      end

    end
  end 
end