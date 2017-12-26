module WPScan
  module Finders
    module DynamicFinder
      module Version
        # Version finder using QueryParameter method
        class QueryParameter < WPScan::Finders::DynamicFinder::Version::Finder
          # @param [ Constant ] mod
          # @param [ Constant ] klass
          # @param [ Hash ] config
          def self.create_child_class(mod, klass, config)
            mod.const_set(
              klass, Class.new(self) do
                const_set(:PATH, config['path'])
                const_set(:FILES, config['files'])
                const_set(:XPATH, config['xpath'])
                const_set(:PATTERN, config['pattern'] || /(?:v|ver|version)\=(?<v>[\d\.]+)/i)
                const_set(:CONFIDENCE_PER_OCCURENCE, config['confidence_per_occurence'] || 10)
              end
            )
          end

          # @param [ Typhoeus::Response ] response
          # @param [ Hash ] opts
          # @return [ Version ]
          def find(response, _opts = {})
            # Multiple versions may appear, even though very unlikely,
            # but specs would need to be reworked to handle that. Kind of a TODO.
            scan_response(response).each do |version_number, occurences|
              return create_version(
                version_number,
                confidence: self.class::CONFIDENCE_PER_OCCURENCE * occurences.size,
                interesting_entries: occurences
              )
            end
          end

          # @param [ Typhoeus::Response ] response
          # @return [ Hash ]
          def scan_response(response)
            found = {}

            target.in_scope_urls(response, xpath) do |url, _tag|
              uri = Addressable::URI.parse(url)

              next unless uri.path =~ path_pattern && uri.query&.match(self.class::PATTERN)
              version = Regexp.last_match[:v].to_s

              found[version] ||= []
              found[version] << url
            end

            found
          end

          # @return [ String ]
          def xpath
            @xpath ||= self.class::XPATH || '//link[@href]|//script[@src]'
          end

          # @return [ Regexp ]
          def path_pattern
            @path_pattern ||= %r{/(?:#{self.class::FILES.join('|')})\z}i
          end
        end
      end
    end
  end
end
