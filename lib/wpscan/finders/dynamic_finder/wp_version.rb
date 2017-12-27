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

        class HeaderPattern < WPScan::Finders::DynamicFinder::Version::HeaderPattern
          include Finder
        end

        class JavascriptVar < WPScan::Finders::DynamicFinder::Version::JavascriptVar
          include Finder
        end

        class QueryParameter < WPScan::Finders::DynamicFinder::Version::QueryParameter
          include Finder

          # TODO: How to have the PATTERN to config['pattern] || /ver=(?<v>[\d\.]+)/i w/o
          # redefining all the create_child_class method ?
        end

        class WpItemQueryParameter < QueryParameter
          # TODO: How to have the PATTERN to config['pattern] || /ver=(?<v>[\d\.]+)/i w/o
          # redefining all the create_child_class method ?

          def xpath
            @xpath ||= self.class::XPATH ||
                       "//link[contains(@href,'#{target.plugins_dir}') or contains(@href,'#{target.themes_dir}')]|" \
                       "//script[contains(@src,'#{target.plugins_dir}') or contains(@src,'#{target.themes_dir}')]"
          end

          def path_pattern
            @pattern ||= %r{
              (?:#{Regexp.escape(target.plugins_dir)}|#{Regexp.escape(target.themes_dir)})/
              [^/]+/
              .*\.(?:css|js)\z
            }ix
          end
        end

        class Xpath < WPScan::Finders::DynamicFinder::Version::Xpath
          include Finder
        end
      end
    end
  end
end
