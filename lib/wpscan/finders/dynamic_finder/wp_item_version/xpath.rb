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
                const_set(:PATTERN, config['pattern'] || /\A(?<version>[\d\.]+)/i)
                const_set(:CONFIDENCE, config['confidence'] || 50)
              end
            )
          end

          # @param [ Typhoeus::Response ] response
          # @param [ Hash ] opts
          # @return [ Version ]
          def find(response, _opts = {})
            response.html.xpath(self.class::XPATH).each do |node|
              next unless node.text =~ self.class::PATTERN && Regexp.last_match[:v]

              return WPScan::Version.new(
                Regexp.last_match[:v],
                found_by: found_by,
                confidence: self.class::CONFIDENCE,
                interesting_entries: ["#{response.effective_url}, Match: '#{Regexp.last_match}'"]
              )
            end
            nil
          end
        end
      end
    end
  end
end
