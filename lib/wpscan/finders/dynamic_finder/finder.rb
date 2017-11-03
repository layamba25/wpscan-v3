module WPScan
  module Finders
    module DynamicFinder
      # To be used as a base when creating a dynamic finder
      class Finder
        # This method has to be overriden in child classes
        # @param [ Mixed ? ] url
        # @param [ Hash ] opts
        # @return [ Array<> ]
        def find(_url, _opts = {})
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

          # Maybe use Browser.get(target.url(self.class::PATH)) ?
          find(target.url(self.class::PATH), opts)
        end
      end
    end
  end
end
