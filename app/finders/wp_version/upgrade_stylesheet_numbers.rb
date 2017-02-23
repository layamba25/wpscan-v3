module WPScan
  module Finders
    module WpVersion
      # Stylesheets Version Finder from Upgrade page
      class UpgradeStylesheetNumbers < InstallStylesheetNumbers
        # @return [ Array<WpVersion> ]
        def aggressive(_opts = {})
          wp_versions(target.url('wp-admin/upgrade.php'))
        end
      end
    end
  end
end
