module WPScan
  module Finders
    module DynamicFinder
      module WpVersion
        module Finder
          def create_version(number, finding_opts)
            return unless WPScan::WpVersion.valid?(number)

            WPScan::WpVersion.new(number, version_finding_opts(finding_opts))
          end
        end

        class BodyPattern < WPScan::Finders::DynamicFinder::Version::BodyPattern
          include Finder
        end

        class Comment < WPScan::Finders::DynamicFinder::Version::Comment
          include Finder
        end

        # class ConfigParser < WPScan::Finders::DynamicFinder::Version::ConfigParser
        #  include Finder
        # end

        class HeaderPattern < WPScan::Finders::DynamicFinder::Version::HeaderPattern
          include Finder
        end

        class JavascriptVar < WPScan::Finders::DynamicFinder::Version::JavascriptVar
          include Finder
        end

        class QueryParameter < WPScan::Finders::DynamicFinder::Version::QueryParameter
          include Finder
        end

        class Xpath < WPScan::Finders::DynamicFinder::Version::Xpath
          include Finder
        end
      end
    end
  end
end
