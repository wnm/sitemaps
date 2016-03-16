module Sitemaps
  module Parser
    require "rexml/document"
    require "time"

    VALID_CHANGEFREQ = %w(always hourly daily weekly monthly yearly never)

    def self.parse(source)
      document = REXML::Document.new(source)
      entries  = document.elements.to_a("/urlset/url").map do |root|
        loc  = parse_loc(root)
        mod  = parse_lastmod(root)
        freq = parse_changefreq(root)
        pri  = parse_priority(root)

        Sitemaps::Entry.new(loc, mod, freq, pri)
      end

      Sitemaps::Sitemap.new(entries)
    end

    def self.parse_loc(root)
      loc  = root.get_text("loc")&.value()
      loc && URI.parse(loc) rescue nil
    end

    def self.parse_lastmod(root)
      mod  = root.get_text("lastmod")&.value()
      mod && Time.parse(mod) rescue nil
    end

    def self.parse_changefreq(root)
      freq  = root.get_text("changefreq")&.value()
      freq && VALID_CHANGEFREQ.include?(freq) ? freq.to_sym : nil
    end

    def self.parse_priority(root)
      priority  = root.get_text("priority")&.value() || "0.5"
      priority && Float(priority) rescue 0.5
    end
  end
end
