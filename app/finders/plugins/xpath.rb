module WPScan
  module Finders
    module Plugins
      # Plugins finder from the Dynamic Finder 'Xpath'
      class Xpath < WPScan::Finders::DynamicFinder::WpItems::Finder
        # @param [ Hash ] opts
        #
        # @return [ Array<Plugin> ]
        def passive(opts = {})
          found = []

          DB::DynamicPluginFinders.passive_xpath_finder_configs.each do |slug, configs|
            configs.each do |klass, config|
              process_response(opts, target.homepage_res, slug, klass, config) { |plugin| found << plugin }
            end
          end

          found
        end

        # @param [ Hash ] opts
        #
        # @return [ Array<Plugin> ]
        def aggressive(opts = {})
          found = []

          DB::DynamicPluginFinders.aggressive_xpath_finder_configs.each do |slug, configs|
            configs.each do |klass, config|
              path     = "wp-content/plugins/#{slug}/#{config['path']}"
              response = Browser.get(target.url(path))

              process_response(opts, response, slug, klass, config) { |plugin| found << plugin }
            end
          end

          found
        end

        # @param [ Typhoeus::Response ] response
        # @yield [ Plugin ] The detected plugin
        def process_response(opts, response, slug, klass, config)
          response.html.xpath(config['xpath']).each do |node|
            next if config['pattern'] && !node.text.match(config['pattern'])

            yield Plugin.new(
              slug,
              target,
              opts.merge(found_by: found_by(klass), confidence: config['confidence'] || 70)
            )
          end
        end
      end
    end
  end
end
