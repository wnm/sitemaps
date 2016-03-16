require 'spec_helper'

describe Sitemaps do

  it 'has a version number' do
    expect(Sitemaps::VERSION).not_to be nil
  end

  context "sitemap" do

    def valid_file
      @valid_file ||= begin
        path = File.join(File.dirname(__FILE__), "./fixtures/sitemap.valid.xml")
        File.read(path).freeze
      end
    end

    def valid_fixture
      @valid_fixture ||= Sitemaps.parse(valid_file)
    end
    
    it "can parse a valid sitemap" do
      sitemap = valid_fixture
      expect(sitemap).not_to be_nil
    end

    it "can present a list of urls" do
      urls = [
        URI.parse("http://www.example.com/"),
        URI.parse("http://www.example.com/c?item=12&desc="),
        URI.parse("http://www.example.com/c?item=73&desc="),
        URI.parse("http://www.example.com/c?item=74&desc="),
        URI.parse("http://www.example.com/c?item=83&desc=")
      ]

      expect(valid_fixture.urls.to_a).to eql(urls)
    end

    it "can present a list of entries, which expose priority, lastmod, etc." do
      SE = Sitemaps::Entry
      entries = [
        SE.new(URI.parse("http://www.example.com/"), Time.parse("2005-01-01"), :monthly, 0.8),
        SE.new(URI.parse("http://www.example.com/c?item=12&desc="), nil, :weekly, 0.5),
        SE.new(URI.parse("http://www.example.com/c?item=73&desc="), Time.parse("2004-12-23"), :weekly, 0.5),
        SE.new(URI.parse("http://www.example.com/c?item=74&desc="), Time.parse("2004-12-23T18:00:15+00:00"), nil, 0.3),
        SE.new(URI.parse("http://www.example.com/c?item=83&desc="), Time.parse("2004-11-23"), nil, 0.5)
      ]

      expect(valid_fixture.entries).to eql(entries)
    end
  end

  context "fetching" do
    it "can fetch an xml sitemap from a url, default options" do
      pending
      Sitemaps.fetch(url)
    end

    it "can fetch an xml sitemap from a url, using a custom fetch proc" do
      pending
      Sitemaps.fetch(url, fetch: custom_proc)
    end

    it "can fetch a recursive sitemap (sitemap indexes, see sitemaps.org" do
      pending
      Sitemaps.fetch(url, recurse: true)
    end
  end

  context "discover" do
    it "can find and fetch a sitemap from a domain" do
      pending
      Sitemaps.discover("http://example.com") #=> xml content
    end

    it "returns nil if no sitemap could be found" do
      pending
      Sitemaps.discover("http://exampleno.com") #=> nil
    end
  end

end
