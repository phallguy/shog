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

  describe "#call" do
    it "without configuration doesn't modify the request" do
      output = formatter.call "TEST", Time.now, nil, "Unformatted"
      expect( output ).to eq "Unformatted\n"
    end

    it "adds severity when at least one is configured" do
      formatter.severity_tag :debug, ->(msg){ msg }
      output = formatter.call "DEBUG", Time.now, nil, "Tagged"

      expect( output ).to eq "[DEBUG] Tagged\n"
    end

    it "adds timestamp when configured" do
      formatter.timestamp
      output = formatter.call "WHEN", "just now", nil, "we missed them"

      expect( output ).to eq "[just now] we missed them\n"
    end

    it "adds progname when configured" do
      formatter.progname
      output = formatter.call "NAME", Time.now, "proggy", "magic"

      expect( output ).to eq "[proggy] magic\n"
    end

    it "adds them all" do
      formatter.configure do
        timestamp
        progname
        severity_tag :debug, ->(msg){ msg }
      end

      output = formatter.call "DEBUG", "NOW", "proggy", "gets them all"
      expect( output ).to eq "[NOW] [proggy] [DEBUG] gets them all\n"
    end
  end

  describe "#formatted_severity_tag" do
    it "buffers to the same size" do
      formatter.severity_tag( :warn ){ |msg| msg }
      formatter.severity_tag( :longer ){ |msg| msg }

      expect( formatter.formatted_severity_tag( "WARN" ) ).to   eq "[WARN  ]"
      expect( formatter.formatted_severity_tag( "LONGER" ) ).to eq "[LONGER]"
    end
  end

  describe "#format_time" do
    it "doesn't change when within expected" do
      expect( formatter.format_time( "10ms".cyan, 30 ) ).to eq "10ms".cyan
    end

    it "is yellow when above expected" do
      expect( formatter.format_time( "50ms", 30 ) ).to eq "50ms".yellow
    end

    it "is yellow when above expected and has existing color" do
      expect( formatter.format_time( "50ms".black, 30 ) ).to eq "50ms".yellow
    end

    it "is red when way above expected" do
      expect( formatter.format_time( "150ms", 30 ) ).to eq "150ms".red
    end

  end

  describe "#match" do
    it "formats a matched line" do
      formatter.match /GET/ do |msg,match|
        "R'DONE"
      end

      result = formatter.call "INFO", Time.now, nil, "Started GET \"/Home\""
      expect( result ).to eq "R'DONE\n"
    end

    it "includes the match" do
      formatter.match /GET/ do |msg,match|
        expect( match ).to be_present
      end

      formatter.call "INFO", Time.now, nil, "Started GET \"/Home\""
    end

    it "doesn't match" do
      result = formatter.call "INFO", Time.now, nil, "Started GET \"/Home\""
      expect( result ).to eq "Started GET \"/Home\"\n"
    end

    it "uses default severity when no matcher is found" do
      formatter.severity( :info ){ |msg| "DEFAULT" }

      result = formatter.call "INFO", Time.now, nil, "Started GET \"/Home\""
      expect( result ).to eq "DEFAULT\n"
    end

    it "matches already colored lines" do
      formatter.match /A\sB/ do |msg, match|
        "Title"
      end

      result = formatter.call "INFO", Time.now, nil, "Colored #{ "A".red } #{ "B".green }"
      expect( result ).to eq "Title\n"
    end
  end

  describe "#silence" do
    it "silences matching logs" do
      formatter.silence /loud/
      output = formatter.call "DEBUG", Time.now, nil, "I'm a really loud message"
      expect(output).to be_nil
    end
  end

  describe "#formatter" do
    it "loads from a symbol" do
      expect( Shog::Formatters::Spec).to receive :configure

      formatter.configure do
        with :spec
      end
    end

    it "lods from a module" do
      expect( Shog::Formatters::Spec).to receive :configure

      formatter.configure do
        with Shog::Formatters::Spec
      end
    end
  end




end