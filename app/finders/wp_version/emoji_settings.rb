module WPScan
  module Finders
    module WpVersion
      # WP Version Finder from the Emoji version parameter
      class EmojiSettings < CMSScanner::Finders::Finder
        # @return [ WpVersion ]
        def passive(_opts = {})
          target.homepage_res.html.xpath('//script[contains(text(), "wpemojiSettings")]').each do |node|
            next unless node.text.to_s =~ %r{wp\-includes\\/js\\/wp\-emoji\-release\.min\.js\?ver=(?<v>[\d\.]+)}i

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
