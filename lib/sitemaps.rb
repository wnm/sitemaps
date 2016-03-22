require "active_support"
require "active_support/core_ext/object/try"
require "active_support/core_ext/object/blank"

require "set"
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

  @default_fetcher = ->(u) { Sitemaps::Fetcher.fetch(u) }

  def self.parse(source)
    Sitemaps::Parser.parse(source)
  end

  def self.fetch(url, fetcher: nil, max_entries: nil, &block)
    fetcher ||= @default_fetcher
    unless url.is_a? URI
      url = "http://#{url}" unless url =~ %r{^https?://}
      url = URI.parse(url)
    end

    _instance.fetch_recursive(url, fetcher, max_entries, &block)
  end

  def self.discover(url, fetcher: nil, max_entries: nil, &block)
    fetcher ||= @default_fetcher
    unless url.is_a? URI
      url = "http://#{url}" unless url =~ %r{^https?://}
      url = URI.parse(url)
    end

    roots = _instance.discover_roots(url, fetcher)
    _instance.fetch_recursive(roots, fetcher, max_entries, &block)
  end

  # PRIVATE
  def self._instance
    @instance ||= Sitemaps::Instance.new
  end

  class Instance
    def fetch_single(url, fetcher, max_entries, &block)
      source = fetcher.call(url)
      Sitemaps::Parser.parse(source, max_entries: max_entries, filter: block)
    end

    def fetch_recursive(urls, fetcher, max_entries, &block)
      queue = urls.is_a?(Array) ? urls : [urls]
      maps  = {}

      # walk the queue, fetching the sitemap requested and adding
      # new sitemaps to the queue as found
      loop do
        begin
          url = queue.pop
          break if url.nil?
          next  unless maps[url].nil?
          
          # fetch this item in the queue, and queue up any sub maps it found
          maps[url] = fetch_single(url, fetcher, max_entries, &block)
          queue.push(*maps[url].sitemaps.map(&:loc))

          # decrement max_entries (since it's max_entries total, not per map)
          unless max_entries.nil?
            max_entries -= maps[url].entries.length
            break if max_entries <= 0
          end
        rescue => ex
          # otherwise keep on going, because we've got something at least
          $stderr.puts "ERROR FETCHING: #{url}, #{ex.message}, ignoring..."
          next
        end
      end

      # collapse the recovered maps into a single one with everything
      result = maps.each_with_object(Sitemap.new([], [])) do |(_, map), result|
        result.sitemaps.concat(map.sitemaps)
        result.entries.concat(map.entries)
      end

      result.sitemaps.uniq! { |e| e.loc.to_s }
      result.entries.uniq!  { |e| e.loc.to_s }
      result
    end

    def discover_roots(url, fetcher)
      # try to fetch a robots.txt, and get sitemaps from there
      robots = begin
        robotsurl      = url.clone
        robotsurl.path = "/robots.txt"
        robotstxt      = fetcher.call(robotsurl)

        robotstxt.scan(/^Sitemap: (.+)$/).flatten
      rescue
        []
      end

      # try for files in a handful of known locations
      known_locations = %w(/sitemap_index.xml.gz /sitemap_index.xml /sitemap.xml.gz /sitemap.xml)
      known_locations = known_locations.map do |path|
        pathurl      = url.clone
        pathurl.path = path
        pathurl
      end

      # return a deduplicated array
      roots = Set.new | robots | known_locations
      roots.to_a
    end
  end
end
