module WPScan
  module Finders
    module Plugins
      # Plugins finder from the Dynamic Finder 'Xpath'
      class Xpath < CMSScanner::Finders::Finder
        # @param [ Hash ] opts
        #
        # @return [ Array<Plugin> ]
        def passive(opts = {})
          found = []

          DB::DynamicPluginFinders.passive_xpath_finder_configs.each do |slug, configs|
            configs.each do |klass, config|
              next unless target.homepage_res.html.xpath(config['xpath']).any?

              found << Plugin.new(slug,
                                  target,
                                  opts.merge(found_by: found_by(klass), confidence: config['confidence'] || 70))
            end
          end

          found
        end

        # @param [ Hash ] opts
        #
        # @return [ Array<Plugin> ]
        def aggressive(_opts = {})
          # TODO
        end
      end
    end
  end
end
