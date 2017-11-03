module WPScan
  module Finders
    module DynamicFinder
      module WpItemVersion
        # Version finder using Xpath method
        class Xpath < Finder
          # @param [ Constant ] mod
          # @param [ Constant ] klass
          # @param [ Hash ] config
          def self.create_child_class(mod, klass, config)
            mod.const_set(
              klass, Class.new(self) do
                const_set(:PATH, config['path'])
                const_set(:XPATH, config['xpath'])
                const_set(:PATTERN, config['pattern'] || /\A(?<version>[\d\.]+)/i)
                const_set(:CONFIDENCE, config['confidence'] || 50)
              end
            )
          end

          # @return [ Version ]
          def find(response, _opts = {})
            # TODO
          end
        end
      end
    end
  end
end
