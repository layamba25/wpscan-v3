module WPScan
  module Finders
    module WpVersion
      # Stylesheets Version Finder from Homepage
      #
      # TODO: Maybe put such methods in the CMSScanner to have a generic
      # way of getting those versions, and allow the confidence to be
      # customised
      class HomepageStylesheetNumbers < CMSScanner::Finders::Finder
        # @return [ Array<WpVersion> ]
        def passive(_opts = {})
          wp_versions(target.homepage_url)
        end

        protected

        # @param [ String ] url
        #
        # @return [ Array<WpVersion> ]
        def wp_versions(url)
          found = []

          scan_page(url).each do |version_number, occurences|
            next unless WPScan::WpVersion.valid?(version_number) # Skip invalid versions

            found << WPScan::WpVersion.new(
              version_number,
              found_by: found_by,
              confidence: 5 * occurences.count,
              interesting_entries: occurences
            )
          end

          found
        end

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
