module WPScan
  module Finders
    module DynamicFinder
      module WpItemVersion
        # Version finder in Comment
        class Comment < Finder
          # @param [ Constant ] mod
          # @param [ Constant ] klass
          # @param [ Hash ] config
          def self.create_child_class(mod, klass, config)
            mod.const_set(
              klass, Class.new(self) do
                const_set(:PATH, config['path'])
                const_set(:PATTERN, config['pattern'])
                const_set(:CONFIDENCE, config['confidence'] || 40)
              end
            )
          end

          # @param [ Typhoeus::Response ] response
          # @param [ Hash ] opts
          # @return [ Version ]
          def find(response, _opts = {})
            # target.target is the WP blog
            target.target.comments_from_page(self.class::PATTERN, response) do |match|
              # Avoid nil version, i.e a pattern allowing both versionable and non
              # versionable string to be detected

              next unless match[1]

              return WPScan::Version.new(
                match[1],
                found_by: found_by,
                confidence: self.class::CONFIDENCE,
                interesting_entries: ["#{response.effective_url}, Match: '#{match}'"]
              )
            end
            nil # In case nothing is found, otherwise the latest match is returned and cause problems
          end
        end
      end
    end
  end
end
