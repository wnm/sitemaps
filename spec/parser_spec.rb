require 'spec_helper'
require 'rexml/document'

describe Sitemaps::Parser do

  def as_doc(str)
    REXML::Document.new(str).root
  end

  it "can parse a location url" do
    root   = as_doc("<url><loc>http://example.com</loc></url>")
    result = Sitemaps::Parser.parse_loc(root)

    expect(result).to eq(URI.parse("http://example.com/"))
  end

  it "handles a missing loc with nil" do
    root   = as_doc("<url></url>")
    result = Sitemaps::Parser.parse_loc(root)

    expect(result).to be_nil
  end

  it "handles a malformed loc with nil" do
    root   = as_doc("<url><lastmod>not a uri</lastmod></url>")
    result = Sitemaps::Parser.parse_loc(root)

    expect(result).to be_nil
  end

  it "can parse a lastmod timestamp" do
    root    = as_doc("<url><lastmod>2016-04-15</lastmod></url>")
    lastmod = Sitemaps::Parser.parse_lastmod(root)

    expect(lastmod).to eq(Time.parse("2016-04-15"))
  end

  it "handles a missing lastmod with nil" do
    root    = as_doc("<url></url>")
    lastmod = Sitemaps::Parser.parse_lastmod(root)

    expect(lastmod).to be_nil
  end

  it "handles a malformed lastmod with nil" do
    root    = as_doc("<url><lastmod>hello</lastmod></url>")
    lastmod = Sitemaps::Parser.parse_lastmod(root)

    expect(lastmod).to be_nil
  end

  it "can parse walid changefreq entries" do
    entries = %w(always hourly daily weekly monthly yearly never)
    entries.each do |e|
      root       = as_doc("<url><changefreq>#{e}</changefreq></url>")
      changefreq = Sitemaps::Parser.parse_changefreq(root)

      expect(changefreq).to equal(e.to_sym)
    end
  end

  it "handles a missing changefreq with nil" do
    root   = as_doc("<url></url>")
    result = Sitemaps::Parser.parse_changefreq(root)

    expect(result).to be_nil
  end

  it "handles an unknown changefreq with nil" do
    root   = as_doc("<url><changefreq>so often man, oh man</changefreq></url>")
    result = Sitemaps::Parser.parse_changefreq(root)

    expect(result).to be_nil
  end

  it "can parse a priority value" do
    root    = as_doc("<url><priority>0.9</priority></url>")
    lastmod = Sitemaps::Parser.parse_priority(root)

    expect(lastmod).to eq(0.9)
  end

  it "handles a missing lastmod with default 0.5" do
    root    = as_doc("<url></url>")
    lastmod = Sitemaps::Parser.parse_priority(root)

    expect(lastmod).to eq(0.5)
  end

  it "handles a malformed lastmod with default 0.5" do
    root    = as_doc("<url><priority>very high</priority></url>")
    lastmod = Sitemaps::Parser.parse_priority(root)

    expect(lastmod).to eq(0.5)
  end

end
