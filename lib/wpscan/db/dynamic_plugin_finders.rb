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
    end
  end
end
