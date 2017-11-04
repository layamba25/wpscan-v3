module WPScan
  module Finders
    module DynamicFinder
      module WpItems
        # Not really a dynamic finder in itself, but will use the dynamic finder DB
        # configs to find collections of WpItems (such as Plugins and Themes)
        class Finder < CMSScanner::Finders::Finder
          # TODO: Put it in the CMSScanner ?
          # @param [ String ] klass
          # @return [ String ]
          def found_by(klass = self)
            caller_locations.each do |call|
              label = call.label

              next unless %w[aggressive passive].include? label

              return "#{klass.titleize} (#{label.capitalize} Detection)"
            end
            nil
          end
        end
      end
    end
  end
end
