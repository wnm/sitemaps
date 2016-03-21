module Sitemaps
  module Parser
    require "time"
    require "rexml/document"
    require "active_support"
    require "active_support/core_ext/object/try"

    def self.parse(source)
      document = REXML::Document.new(source)
      entries  = document.elements.to_a("/urlset/url").map do |root|
        loc  = parse_loc(root)
        next if loc.nil?

        mod  = parse_lastmod(root)
        freq = parse_changefreq(root)
        pri  = parse_priority(root)

        Sitemaps::Entry.new(loc, mod, freq, pri)
      end

      sitemaps = document.elements.to_a("/sitemapindex/sitemap").map do |root|
        loc  = parse_loc(root)
        mod  = parse_lastmod(root)

        Sitemaps::Submap.new(loc, mod)
      end

      Sitemaps::Sitemap.new(entries, sitemaps)
    end

    def self.parse_loc(root)
      loc  = root.get_text("loc").try(:value)
      loc && URI.parse(loc) rescue nil
    end

    def self.parse_lastmod(root)
      mod  = root.get_text("lastmod").try(:value)
      mod && Time.parse(mod) rescue nil
    end

    VALID_CHANGEFREQ = %w(always hourly daily weekly monthly yearly never)
    def self.parse_changefreq(root)
      freq  = root.get_text("changefreq").try(:value)
      freq && VALID_CHANGEFREQ.include?(freq) ? freq.to_sym : nil
    end

    def self.parse_priority(root)
      priority  = root.get_text("priority").try(:value) || "0.5"
      priority && Float(priority) rescue 0.5 # default priority according to spec
    end
  end
end
