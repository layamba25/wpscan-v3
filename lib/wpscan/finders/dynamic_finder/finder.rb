module WPScan
  module Finders
    module DynamicFinder
      # To be used as a base when creating a dynamic finder
      class Finder
        # Has to be overriden in child classes
        #
        # @param [ Constant ] mod
        # @param [ Constant ] klass
        # @param [ Hash ] config
        def self.create_child_class(_mod, _klass, _config)
          raise NoMethodError
        end

        # This method has to be overriden in child classes
        #
        # @param [ Typhoeus::Response ] response
        # @param [ Hash ] opts
        # @return [ Mixed ]
        def find(_response, _opts = {})
          raise NoMethodError
        end

        # @param [ Hash ] opts
        def passive(opts = {})
          return if self.class::PATH

          find(target.homepage_res, opts)
        end

        # @param [ Hash ] opts
        def aggressive(opts = {})
          return unless self.class::PATH

          find(browser.get(target.url(self.class::PATH)), opts)
        end
      end
    end
  end
end
