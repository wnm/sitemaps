module Sitemaps
  Entry   = Struct.new(:loc, :lastmod, :changefreq, :priority)
  Submap  = Struct.new(:loc, :lastmod)
  Sitemap = Struct.new(:entries, :sitemaps)

  class FetchError < StandardError; end

  @default_fetch = -> (uri) do
    resp = Net::HTTP.get_response(uri)
    raise FetchError, "Failed to fetch URI, #{resp.code}" unless resp.code.to_s =~ /2\d\d/
    resp.body
  end

  def self.parse(source)
    Sitemaps::Parser.parse(source)
  end

  def self.fetch(url, fetch: nil, recurse: true)
    fetch ||= @default_fetch
    recurse ? fetch_recursive(url, fetch) : fetch_single(url, fetch)
  end

private

  def self.fetch_single(url, fetch)
    source = fetch.call(parse_url(url))
    Sitemaps::Parser.parse(source)
  end

  def self.fetch_recursive(url, fetch)
    queue, maps = [url], {}
    loop do
      begin
        url = queue.pop
        break if url.nil? 
        next  unless maps[url].nil?

        maps[url] = fetch_single(url, fetch)
        queue.push(*maps[url].sitemaps.map(&:loc))
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

    url = "http://#{url}" unless url =~ /^https?/
    URI.parse(url)
  end
end

require "sitemaps/version"
require "sitemaps/parser"
