require 'wpscan/finders/finder/wp_version/smart_url_checker'
require 'wpscan/finders/finder/plugin_version/comments'

require 'wpscan/finders/dynamic_finder/finder'
require 'wpscan/finders/dynamic_finder/wp_item_version/finder'
require 'wpscan/finders/dynamic_finder/wp_item_version/comment'
require 'wpscan/finders/dynamic_finder/wp_item_version/xpath'

module WPScan
  # Custom Finders
  module Finders
    include CMSScanner::Finders

    # Custom InterestingFindings
    module InterestingFindings
      include CMSScanner::Finders::InterestingFindings
    end
  end
end
