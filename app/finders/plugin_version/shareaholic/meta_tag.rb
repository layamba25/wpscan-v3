module WPScan
  module Finders
    module PluginVersion
      module Shareaholic
        # Version from the meta
        class MetaTag < CMSScanner::Finders::Finder
          # @param [ Hash ] opts
          #
          # @return [ Version ]
          def passive(_opts = {})
            target.target.homepage_res.html.css('meta[name="shareaholic:wp_version"]').each do |node|
              next unless node['content'] =~ /\A([0-9\.]+)/i

              return WPScan::Version.new(
                Regexp.last_match(1),
                found_by: found_by,
                confidence: 50,
                interesting_entries: ["#{target.target.url}, Match: '#{node.to_s.strip}'"]
              )
            end
            nil
          end
        end
      end
    end
  end
end
