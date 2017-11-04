module WPScan
  module Finders
    module Plugins
      # Plugins detected from the Dynamic Finder 'Comment'
      class Comment < CMSScanner::Finders::Finder
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
              configs.each do |found_by_class, config|
                next unless comment =~ config['pattern']

                found_by = "#{found_by_class.titleize} (Passive Detection)"
                plugin   = WPScan::Plugin.new(slug,
                                              target,
                                              opts.merge(found_by: found_by, confidence: config['confidence'] || 50))

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
