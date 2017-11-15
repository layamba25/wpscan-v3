module WPScan
  module Finders
    module Plugins
      # Plugins finder from Dynamic Finder 'BodyPattern'
      class BodyPattern < WPScan::Finders::DynamicFinder::WpItems::Finder
        # @param [ Hash ] opts The options from the #passive, #aggressive methods
        # @param [ Typhoeus::Response ] response
        # @param [ String ] slug
        # @param [ String ] klass
        # @param [ Hash ] config The related dynamic finder config hash
        #
        # @return [ Plugin ] The detected plugin
        def process_response(opts, response, slug, klass, config)
          return unless response.body =~ config['pattern']

          Plugin.new(
            slug,
            target,
            opts.merge(found_by: found_by(klass), confidence: config['confidence'] || 70)
          )
        end
      end
    end
  end
end
