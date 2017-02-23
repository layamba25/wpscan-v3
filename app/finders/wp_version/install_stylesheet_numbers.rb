module WPScan
  module Finders
    module WpVersion
      # Stylesheets Version Finder from Install page
      class InstallStylesheetNumbers < HomepageStylesheetNumbers
        # Overrides the parent
        def passive(_ops = {}); end

        # @return [ Array<WpVersion> ]
        def aggressive(_opts = {})
          wp_versions(target.url('wp-admin/install.php'))
        end
      end
    end
  end
end
