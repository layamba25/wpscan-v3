module WPScan
  module Finders
    module Plugins
      # Plugins finder from the Dynamic Finder 'Comment'
      class Comment < WPScan::Finders::DynamicFinder::WpItems::Finder
        # @param [ Hash ] opts
        # @option opts [ Boolean ] :unique Default: true
        #
        # @return [ Array<Plugin> ]
        def passive(opts = {})
          found         = []
          opts[:unique] = true unless opts.key?(:unique)

          finder_configs = DB::DynamicPluginFinders.passive_comment_finder_configs

          target.homepage_res.html.xpath('//comment()').each do |node|
            comment = node.text.to_s.strip

            finder_configs.each do |slug, configs|
              configs.each do |klass, config|
                next unless comment =~ config['pattern']

                plugin = Plugin.new(slug,
                                    target,
                                    opts.merge(found_by: found_by(klass), confidence: config['confidence'] || 50))

                found << plugin unless opts[:unique] && found.include?(plugin)
              end
            end
          end

          found
        end

        def aggressive(_opts = {})
          # TODO
          # DB::DynamicPluginFinders.aggressive_comment_finder_configs.each do |slug, configs|
          # end
        end
      end
    end
  end
end
