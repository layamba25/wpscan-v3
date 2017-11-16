require_relative 'wp_version/meta_generator'
require_relative 'wp_version/rss_generator'
require_relative 'wp_version/atom_generator'
require_relative 'wp_version/rdf_generator'
require_relative 'wp_version/readme'
require_relative 'wp_version/sitemap_generator'
require_relative 'wp_version/opml_generator'
require_relative 'wp_version/homepage_stylesheet_numbers'
require_relative 'wp_version/install_stylesheet_numbers'
require_relative 'wp_version/upgrade_stylesheet_numbers'
require_relative 'wp_version/unique_fingerprinting'
require_relative 'wp_version/addthis_javascript_var'

module WPScan
  module Finders
    # Specific Finders container to filter the version detected
    # and remove the one with low confidence to avoid false
    # positive when there is not enought information to accurately
    # determine it.
    class WpVersionFinders < UniqueFinders
      def filter_findings
        best_finding = super

        best_finding.confidence >= 40 ? best_finding : false
      end
    end

    module WpVersion
      # Wp Version Finder
      class Base
        include CMSScanner::Finders::UniqueFinder

        # @param [ WPScan::Target ] target
        def initialize(target)
          %i[
            MetaGenerator RSSGenerator AtomGenerator HomepageStylesheetNumbers InstallStylesheetNumbers
            UpgradeStylesheetNumbers RDFGenerator Readme SitemapGenerator OpmlGenerator
            AddthisJavascriptVar UniqueFingerprinting
          ].each do |sym|
            finders << WpVersion.const_get(sym).new(target)
          end
        end

        def finders
          @finders ||= Finders::WpVersionFinders.new
        end
      end
    end
  end
end
