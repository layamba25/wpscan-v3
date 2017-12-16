module WPScan
  module Finders
    module DynamicFinder
      module WpItemVersion
        # Version finder using by parsing config files, such as composer.json
        # and so on
        class ConfigParser < WPScan::Finders::DynamicFinder::WpItemVersion::Finder
          ALLOWED_PARSERS = [JSON, YAML].freeze

          # @param [ Constant ] mod
          # @param [ Constant ] klass
          # @param [ Hash ] config
          def self.create_child_class(mod, klass, config)
            mod.const_set(
              klass, Class.new(self) do
                const_set(:PATH, config['path'])
                const_set(:PARSER, config['parser'])
                const_set(:KEY, config['key'])
                const_set(:PATTERN, config['pattern'] || /(?<v>[\d\.]+)/i)
                const_set(:CONFIDENCE, config['confidence'] || 40)
              end
            )
          end

          # @param [ String ] body
          # @return [ Hash, nil ] The parsed body, with an available parser, if possible
          def parse(body)
            parsers = ALLOWED_PARSERS.include?(self.class::PARSER) ? [self.class::PARSER] : ALLOWED_PARSERS

            parsers.each do |parser|
              begin
                return parser.respond_to?(:safe_load) ? parser.safe_load(body) : parser.load(body)
              rescue StandardError
                next
              end
            end

            nil # Make sure nil is returned in case none of the parsers manage to parse the body correctly
          end

          # No Passive way
          def passive(opts = {}); end

          # @param [ Typhoeus::Response ] response
          # @param [ Hash ] opts
          # @return [ Version ]
          def find(response, _opts = {})
            parsed_body = parse(response.body)

            return unless (data = parsed_body&.dig(*self.class::KEY.split(':'))) && data =~ self.class::PATTERN

            WPScan::Version.new(
              Regexp.last_match[:v],
              found_by: found_by,
              confidence: self.class::CONFIDENCE,
              interesting_entries: ["#{response.effective_url}, Match: '#{Regexp.last_match}'"]
            )
          end
        end
      end
    end
  end
end
