module WPScan
  module Finders
    module Plugins
      # Plugins finder from the Dynamic Finder 'JavascriptVar'
      class JavascriptVar < WPScan::Finders::DynamicFinder::WpItems::Finder
        # @param [ Hash ] opts
        #
        # @return [ Array<Plugin> ]
        def passive(opts = {})
          found = []

          DB::DynamicPluginFinders.passive_javascript_var_finder_configs.each do |slug, configs|
            configs.each do |klass, config|
              target.homepage_res.html.xpath('//script[not(@src)]').each do |node|
                next if config['pattern'] && !node.text.match(config['pattern'])

                found << Plugin.new(
                  slug,
                  target,
                  opts.merge(found_by: found_by(klass), confidence: config['confidence'] || 60)
                )
              end
            end
          end

          found
        end

        # @param [ Hash ] opts
        #
        # @return [ Array<Plugin> ]
        def aggressive(_opts = {})
          # TODO
          # DB::DynamicPluginFinders.aggressive_javascript_var_finder_configs.each do |slug, configs|
          # end
        end
      end
    end
  end
end
