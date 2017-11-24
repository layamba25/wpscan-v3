module WPScan
  module Finders
    module DynamicFinder
      module WpItemVersion
        # Version finder using Header Pattern method
        class QueryParameter < WPScan::Finders::DynamicFinder::WpItemVersion::Finder
          # @param [ Constant ] mod
          # @param [ Constant ] klass
          # @param [ Hash ] config
          def self.create_child_class(mod, klass, config)
            mod.const_set(
              klass, Class.new(self) do
                const_set(:PATH, config['path'])
                const_set(:FILES, config['files'])
                const_set(:PATTERN, config['pattern'] || /(?:v|ver)\=(?<v>[\d\.]+)/i)
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
              return WPScan::Version.new(
                version_number,
                found_by: found_by,
                confidence: self.class::CONFIDENCE_PER_OCCURENCE * occurences.size,
                interesting_entries: occurences
              )
            end
          end

          # @param [ Typhoeus::Response ] response
          # @return [ Hash ]
          def scan_response(response)
            found   = {}
            pattern = %r{
              #{Regexp.escape(target.target.plugins_dir)}/
              #{Regexp.escape(target.slug)}/
              (?:#{self.class::FILES.join('|')})\z
            }ix

            target.target.in_scope_urls(response, '//link|//script') do |url, _tag|
              uri = Addressable::URI.parse(url)

              next unless uri.path =~ pattern && uri.query&.match(self.class::PATTERN)
              version = Regexp.last_match[:v].to_s

              found[version] ||= []
              found[version] << url
            end

            found
          end
        end
      end
    end
  end
end
