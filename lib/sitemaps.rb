module Sitemaps
  Entry   = Struct.new(:loc, :lastmod, :changefreq, :priority)
  Submap  = Struct.new(:loc, :lastmod)
  Sitemap = Struct.new(:entries, :sitemaps)

  def self.parse(source)
    Sitemaps::Parser.parse(source)
  end
end

require "sitemaps/version"
require "sitemaps/parser"
