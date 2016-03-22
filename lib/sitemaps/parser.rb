module Sitemaps
  # Parse XML Sitemaps
  module Parser
    def self.parse(source, max_entries: nil, filter: nil)
      document = REXML::Document.new(source)
      entries  = document.elements.to_a("/urlset/url").map do |root|
        loc  = parse_loc(root) || next
        mod  = parse_lastmod(root)
        freq = parse_changefreq(root)
        pri  = parse_priority(root)

        entry = Sitemaps::Entry.new(loc, mod, freq, pri)
        (!filter || filter.call(entry)) ? entry : nil
      end.reject(&:nil?)
      entries = entries.take(max_entries) unless max_entries.nil?

      sitemaps = document.elements.to_a("/sitemapindex/sitemap").map do |root|
        loc  = parse_loc(root) || next
        mod  = parse_lastmod(root)

        Sitemaps::Submap.new(loc, mod)
      end.reject(&:nil?)

      Sitemaps::Sitemap.new(entries, sitemaps)
    end

    def self.parse_loc(root)
      loc = root.get_text("loc").try(:value)
      loc && URI.parse(loc) rescue nil
    end

    def self.parse_lastmod(root)
      mod = root.get_text("lastmod").try(:value)
      mod && Time.parse(mod) rescue nil
    end

    VALID_CHANGEFREQ = %w(always hourly daily weekly monthly yearly never).freeze
    def self.parse_changefreq(root)
      freq = root.get_text("changefreq").try(:value)
      freq && VALID_CHANGEFREQ.include?(freq) ? freq.to_sym : nil
    end

    def self.parse_priority(root)
      priority = root.get_text("priority").try(:value) || "0.5"
      priority && Float(priority) rescue 0.5 # default priority according to spec
    end
  end
end
