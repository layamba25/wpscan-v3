module WPScan
  module Finders
    module DynamicFinder
      module WpItems
        # Not really a dynamic finder in itself, but will use the dynamic finder DB
        # configs to find collections of WpItems (such as Plugins and Themes)
        class Finder < CMSScanner::Finders::Finder
          # Will probably need this in a near future
          # to factorise code
        end
      end
    end
  end
end
