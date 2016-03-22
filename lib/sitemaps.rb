require "active_support"
require "active_support/core_ext/object/try"
require "active_support/core_ext/object/blank"

require "time"
require "rexml/document"

require "sitemaps/version"
require "sitemaps/parser"
require "sitemaps/fetcher"

# Discover, fetch and parse XML sitemaps as defined by the `http://sitemaps.org` spec.
module Sitemaps
  Entry   = Struct.new(:loc, :lastmod, :changefreq, :priority)
  Submap  = Struct.new(:loc, :lastmod)
  Sitemap = Struct.new(:entries, :sitemaps)

  def self.parse(source)
    Sitemaps::Parser.parse(source)
  end

  def self.fetch(url, fetch: nil, recurse: true, max_entries: nil, &block)
    fetch ||= -> (u) { Sitemaps::Fetcher.fetch(u) }
    url     = parse_url(url)

    recurse ? fetch_recursive(url, fetch, max_entries, &block) : fetch_single(url, fetch, max_entries, &block)
  end

  def self.fetch_single(url, fetch, max_entries, &block)
    url    = parse_url(url)
    source = fetch.call(url)

    Sitemaps::Parser.parse(source, max_entries: max_entries, filter: block)
  end

  def self.fetch_recursive(url, fetch, max_entries, &block)
    queue = [parse_url(url)]
    maps  = {}

    # walk the queue, fetching the sitemap requested and adding
    # new sitemaps to the queue as found
    loop do
      begin
        url = queue.pop
        break if url.nil?
        next  unless maps[url].nil?

        # fetch this item in the queue, and queue up any sub maps it found
        maps[url] = fetch_single(url, fetch, max_entries, &block)
        queue.push(*maps[url].sitemaps.map(&:loc))

        # decrement max_entries (since it's max_entries total, not per map)
        unless max_entries.nil?
          max_entries -= maps[url].entries.length
          break if max_entries <= 0
        end
      rescue => ex
        $stderr.puts "ERROR FETCHING: #{url}, #{ex.message}, ignoring..."
        next
      end
    end

    # collapse the recovered maps into a single one with everything
    maps.each_with_object(Sitemap.new([], [])) do |(_, map), result|
      result.sitemaps.concat(map.sitemaps)
      result.entries.concat(map.entries)
    end
  end

  def self.parse_url(url)
    return url if url.is_a? URI

    url = "http://#{url}" unless url =~ %r{^https?://}
    URI.parse(url)
  end
end
