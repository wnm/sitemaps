# Sitemaps

Discover, retrieve and parse XML sitemaps, according to the spec at [sitemaps.org](http://sitemaps.org).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sitemaps'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sitemaps

## Usage

```ruby
require 'sitemaps'

# parse a sitemap from a string
Sitemaps.parse("<xml ns=\"...")

# fetch and parse a sitemap from a known url
sitemap = Sitemaps.fetch("http://google.com/sitemap.xml", recurse: true)

# sitemap usage
sitemap.entries.first #> Struct(loc: 'http://example.com/page', lastmod: DateTime.utc, changefreq: :monthly, priority: 0.5)
urls = sitemap.entries.map(&:loc)

## Development

## TODO

* discovery
* sorting by last modified, or priority
* filtering by last modified

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/termscout/sitemaps. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
