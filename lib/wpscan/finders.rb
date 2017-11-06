require 'wpscan/finders/finder/wp_version/smart_url_checker'

require 'wpscan/finders/dynamic_finder/finder'
require 'wpscan/finders/dynamic_finder/wp_items/finder'
require 'wpscan/finders/dynamic_finder/wp_item_version/finder'
require 'wpscan/finders/dynamic_finder/wp_item_version/xpath'
require 'wpscan/finders/dynamic_finder/wp_item_version/comment'
require 'wpscan/finders/dynamic_finder/wp_item_version/header_pattern'
require 'wpscan/finders/dynamic_finder/wp_item_version/body_pattern'

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
