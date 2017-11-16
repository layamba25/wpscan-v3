module WPScan
  module Finders
    module WpVersion
      # WP Version Finder from the Javscript Variables in Addthis
      class AddthisJavascriptVar < CMSScanner::Finders::Finder
        # @return [ WpVersion ]
        def passive(_opts = {})
          target.homepage_res.html.xpath('//script[@data-cfasync="false"]').each do |node|
            next unless node.text.to_s =~ /wp_blog_version\s*\=\s*"(?<v>[\d\.]+)";/i

            number = Regexp.last_match[:v]

            next unless WPScan::WpVersion.valid?(number)

            return WPScan::WpVersion.new(
              number,
              found_by: found_by,
              confidence: 70,
              interesting_entries: ["#{target.url}, Match: '#{Regexp.last_match}'"]
            )
          end
          nil
        end
      end
    end
  end
end
