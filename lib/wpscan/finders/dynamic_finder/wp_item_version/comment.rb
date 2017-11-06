module WPScan
  module Finders
    module DynamicFinder
      module WpItemVersion
        # Version finder in Comment, which is basically an Xpath one with a default
        # Xpath of //comment()
        class Comment < WPScan::Finders::DynamicFinder::WpItemVersion::Xpath
          # @param [ Constant ] mod
          # @param [ Constant ] klass
          # @param [ Hash ] config
          def self.create_child_class(mod, klass, config)
            mod.const_set(
              klass, Class.new(self) do
                const_set(:PATH, config['path'])
                const_set(:XPATH, config['xpath'] || '//comment()')
                const_set(:PATTERN, config['pattern'])
                const_set(:CONFIDENCE, config['confidence'] || 50)
              end
            )
          end
        end
      end
    end
  end
end
