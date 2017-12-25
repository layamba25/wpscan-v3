module WPScan
  module Finders
    module DynamicFinder
      module WpItemVersion
        # Version finder using Xpath method
        class Xpath < WPScan::Finders::DynamicFinder::WpItemVersion::Finder
          # @param [ Constant ] mod
          # @param [ Constant ] klass
          # @param [ Hash ] config
          def self.create_child_class(mod, klass, config)
            mod.const_set(
              klass, Class.new(self) do
                const_set(:PATH, config['path'])
                const_set(:XPATH, config['xpath'])
                const_set(:PATTERN, config['pattern'] || /\A(?<v>[\d\.]+)/i)
                const_set(:CONFIDENCE, config['confidence'] || 40)
              end
            )
          end

          # @param [ Typhoeus::Response ] response
          # @param [ Hash ] opts
          # @return [ Version ]
          def find(response, _opts = {})
            target.xpath_pattern_from_page(
              self.class::XPATH, self.class::PATTERN, response
            ) do |match_data, _node|
              next unless match_data[:v]

              return create_version(
                match_data[:v],
                interesting_entries: ["#{response.effective_url}, Match: '#{match_data}'"]
              )
            end
            nil
          end
        end
      end
    end
  end
end
