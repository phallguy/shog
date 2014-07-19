require 'spec_helper'

module Shog::Formatters::Spec
  module_function
  def configure( formatter )
    formatter.configure do
      severity :test, ->{}
    end
  end
end

describe Shog::Formatter do
  let(:formatter){ Shog::Formatter.new }

  describe "#formatted_severity_tag" do
    it "buffers to the same size" do
      formatter.severity_tag( :warn ){ |msg| msg }
      formatter.severity_tag( :longer ){ |msg| msg }

      expect( formatter.formatted_severity_tag( "WARN" ) ).to   eq "WARN  "
      expect( formatter.formatted_severity_tag( "LONGER" ) ).to eq "LONGER"
    end
  end

  describe "#match" do
    it "formats a matched line" do
      formatter.match /GET/ do |msg,match|
        "R'DONE"
      end

      result = formatter.call "INFO", Time.now, nil, "Started GET \"/Home\""
      expect( result ).to eq "[INFO] R'DONE\n"
    end

    it "includes the match" do
      formatter.match /GET/ do |msg,match|
        expect( match ).to be_present
      end

      formatter.call "INFO", Time.now, nil, "Started GET \"/Home\""
    end

    it "doesn't match" do
      result = formatter.call "INFO", Time.now, nil, "Started GET \"/Home\""
      expect( result ).to eq "[INFO] Started GET \"/Home\"\n"
    end

    it "uses default severity when no matcher is found" do
      formatter.severity( :info ){ |msg| "DEFAULT" }

      result = formatter.call "INFO", Time.now, nil, "Started GET \"/Home\""
      expect( result ).to eq "[INFO] DEFAULT\n"
    end
  end

  describe "#formatters" do
    it "loads from a symbol" do
      formatter.should_receive(:severity).with(:test, anything())

      formatter.configure do
        formatter :spec
      end
    end
  end


end