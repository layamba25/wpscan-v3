module WPScan
  module Finders
    module Plugins
      # Plugins from Comments Finder
      class Comments < CMSScanner::Finders::Finder
        # @param [ Hash ] opts
        # @option opts [ Boolean ] :unique Default: true
        #
        # @return [ Array<Plugin> ]
        def passive(opts = {})
          found         = []
          opts[:unique] = true unless opts.key?(:unique)

          target.homepage_res.html.xpath('//comment()').each do |node|
            comment = node.text.to_s.strip

            DB::DynamicPluginFinders.passive_comment_finder_configs.each do |slug, config|
              # TODO: Consider case of multiple configs for the same slug, ie with the class
              # parameter in the YML
              next unless comment =~ config['Comment']['pattern']

              plugin = WPScan::Plugin.new(slug, target, opts.merge(found_by: found_by, confidence: 70))

              found << plugin unless opts[:unique] && found.include?(plugin)
            end
          end

          found
        end
      end
    end
  end
end
