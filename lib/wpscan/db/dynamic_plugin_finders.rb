module WPScan
  module DB
    # Dynamic Plugin Finders
    class DynamicPluginFinders < DynamicFinders
      # @return [ Hash ]
      def self.db_data
        @db_data ||= super['plugins'] || {}
      end

      def self.version_finder_module
        Finders::PluginVersion
      end

      # @return [ Hash ]
      def self.comments
        @comments ||= finder_configs('Comment')
      end

      # @return [ Hash ]
      def self.urls_in_page
        @urls_in_page ||= finder_configs('UrlsInPage')
      end
    end
  end
end
