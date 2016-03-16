module Sitemaps
  Entry = Struct.new(:loc, :lastmod, :changefreq, :priority) do
  end

  Sitemap = Struct.new(:entries) do
    def urls
      self.entries.lazy.map { |e| e.loc }
    end
  end

  def self.parse(source)
    Sitemaps::Parser.parse(source)
  end
end

require "sitemaps/version"
require "sitemaps/parser"
