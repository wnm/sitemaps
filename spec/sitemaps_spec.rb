require 'spec_helper'

describe Sitemaps do
  include SitemapFixtures

  it 'has a version number' do
    expect(Sitemaps::VERSION).not_to be nil
  end

  context "sitemap" do
    it "can parse a valid sitemap" do
      sitemap = sitemap_fixture
      expect(sitemap).not_to be_nil
    end

    it "can present a list of entries" do
      SE = Sitemaps::Entry
      entries = [
        SE.new(URI.parse("http://www.example.com/"), Time.parse("2005-01-01"), :monthly, 0.8),
        SE.new(URI.parse("http://www.example.com/c?item=12&desc="), nil, :weekly, 0.5),
        SE.new(URI.parse("http://www.example.com/c?item=73&desc="), Time.parse("2004-12-23"), :weekly, 0.5),
        SE.new(URI.parse("http://www.example.com/c?item=74&desc="), Time.parse("2004-12-23T18:00:15+00:00"), nil, 0.3),
        SE.new(URI.parse("http://www.example.com/c?item=83&desc="), Time.parse("2004-11-23"), nil, 0.5)
      ]

      expect(sitemap_fixture.entries).to eql(entries)
    end

    it "skips entries with a malformed or missing `loc`" do
      SE = Sitemaps::Entry
      entries = [
        SE.new(URI.parse("http://www.example.com/"), Time.parse("2005-01-01"), :monthly, 0.8)
      ]

      # there are 3 entries defined in the file, but two have unparsable locations
      expect(invalid_fixture.entries).to eql(entries)
    end
  end

  context "sitemap_index" do
    it "can parse a valid sitemap index" do
      sitemap = sitemap_index_fixture
      expect(sitemap).not_to be_nil
    end

    it "can present a list of entries" do
      SM = Sitemaps::Submap
      entries = [
        SM.new(URI.parse("http://www.example.com/sitemap1.xml.gz"), Time.parse("2004-10-01T18:23:17+00:00")),
        SM.new(URI.parse("http://www.example.com/sitemap2.xml.gz"), Time.parse("2005-01-01"))
      ]

      expect(sitemap_index_fixture.sitemaps).to eql(entries)
    end
  end

  context "fetching" do
    xit "can fetch an xml sitemap from a url, default options" do
      Sitemaps.fetch(url)
    end

    xit "can fetch an xml sitemap from a url, using a custom fetch proc" do
      Sitemaps.fetch(url, fetch: custom_proc)
    end

    xit "can fetch a recursive sitemap (sitemap indexes, see sitemaps.org" do
      Sitemaps.fetch(url, recurse: true)
    end
  end

  context "discover" do
    xit "can find and fetch a sitemap from a domain" do
      Sitemaps.discover("http://example.com") #=> xml content
    end

    xit "returns nil if no sitemap could be found" do
      Sitemaps.discover("http://exampleno.com") #=> nil
    end
  end

end
