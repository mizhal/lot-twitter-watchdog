require 'spec_helper'

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
          config.tasks = [
            Lot::TwitterWatchdog::TwitterGraphGenerator.new(nil, catalog, LINK_LIMIT)
          ]
        end

        expect(catalog.TwitterLink.count).to be(LINK_LIMIT * 2), "followers and following count doesnt match"

        catalog.TwitterTarget.destroy_all
        catalog.TwitterLink.destroy_all

      end

    end
  end 
end