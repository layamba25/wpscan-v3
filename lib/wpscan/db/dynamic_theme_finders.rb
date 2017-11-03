module WPScan
  module DB
    # Dynamic Theme Finders (none ATM)
    class DynamicThemeFinders < DynamicFinders
      # @return [ Hash ]
      def self.db_data
        @db_data ||= super['themes'] || {}
      end

      def self.version_finder_module
        Finders::ThemeVersion
      end
    end
  end
end
