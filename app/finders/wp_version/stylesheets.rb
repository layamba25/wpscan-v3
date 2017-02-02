module WPScan
  module Finders
    module WpVersion
      # Stylesheets Version Finder
      class Stylesheets < CMSScanner::Finders::Finder
        # @return [ WpVersion ]
        def passive(_opts = {})
          found = []

          scan_page(target.homepage_url).each do |version_number, occurences|
            next unless WPScan::WpVersion.valid?(version_number) # Skip invalid versions

            found << WPScan::WpVersion.new(
              version_number,
              found_by: 'Stylesheet Numbers (Passive Detection)',
              confidence: 5 * occurences.count,
              interesting_entries: occurences
            )
          end

          found
        end

        protected

        # @param [ String ] url
        #
        # @return [ Hash ]
        def scan_page(url)
          found   = {}
          pattern = /\bver=([0-9\.]+)/i

          target.in_scope_urls(Browser.get(url), '//link|//script') do |stylesheet_url, _tag|
            uri = Addressable::URI.parse(stylesheet_url)
            next unless uri.query && uri.query.match(pattern)

            version = Regexp.last_match[1].to_s

            found[version] ||= []
            found[version] << stylesheet_url
          end

          found
        end
      end
    end
  end
end
