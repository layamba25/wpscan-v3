module WPScan
  module Finders
    module DynamicFinder
      module WpItemVersion
        # To be used as a base when creating
        # a dynamic finder to find the version of a WP Item (such as theme/plugin)
        class Finder < Finders::DynamicFinder::Finder
          # @param [ Hash ] opts
          def passive(opts = {})
            return if self.class::PATH

            # target is the WP item (theme/plugin)
            # target.target is the WP blog
            find(target.target.homepage_res, opts)
          end
        end
      end
    end
  end
end
