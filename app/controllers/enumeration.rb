require_relative 'enumeration/cli_options'
require_relative 'enumeration/enum_methods'

module WPScan
  module Controller
    # Enumeration Controller
    class Enumeration < CMSScanner::Controller::Base
      def before_scan
        # DB::DynamicPluginFinders.create_versions_finders
        # DB::DynamicThemeFinders.create_versions_finders

        # Create the Dynamic PluginVersion Finders
        DB::DynamicPluginFinders.db_data.each do |slug, config|
          %w[Comments].each do |klass|
            next unless config[klass] && config[klass]['version']

            constant_name = slug.tr('-', '_').camelize.to_sym

            unless Finders::PluginVersion.constants.include?(constant_name)
              Finders::PluginVersion.const_set(constant_name, Module.new)
            end

            mod = WPScan::Finders::PluginVersion.const_get(constant_name)

            raise "#{mod} has already a #{klass} class" if mod.constants.include?(klass.to_sym)

            case klass
            when 'Comments' then create_plugins_comments_finders(mod, config[klass])
            end
          end
        end
      end

      def create_plugins_comments_finders(mod, config)
        mod.const_set(
          :Comments, Class.new(Finders::Finder::PluginVersion::Comments) do
            const_set(:PATTERN, config['pattern'])
          end
        )
      end

      def run
        enum = parsed_options[:enumerate] || {}

        enum_plugins if enum_plugins?(enum)
        enum_themes  if enum_themes?(enum)

        %i[timthumbs config_backups medias].each do |key|
          send("enum_#{key}".to_sym) if enum.key?(key)
        end

        enum_users if enum_users?(enum)
      end
    end
  end
end
