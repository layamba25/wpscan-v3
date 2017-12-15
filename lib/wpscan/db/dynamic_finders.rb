module WPScan
  module DB
    # Dynamic Finders
    class DynamicFinders
      # TODO: Put that as class var to allow it to be overriden
      ALLOWED_CLASSES = %i[Comment Xpath HeaderPattern BodyPattern JavascriptVar QueryParameter].freeze

      # @return [ String ]
      def self.db_file
        @db_file ||= File.join(DB_DIR, 'dynamic_finders.yml')
      end

      # @return [ Hash ]
      def self.db_data
        @db_data ||= YAML.safe_load(File.read(db_file), [Regexp])
      end

      # @param [ Symbol ] finder_class
      # @return [ Hash ]
      def self.finder_configs(finder_class, aggressive = false)
        configs = {}

        return configs unless ALLOWED_CLASSES.include?(finder_class)

        db_data.each do |slug, finders|
          # Quite sure better can be done with some kind of logic statement in the select
          fs = if aggressive
                 finders.reject { |_f, c| c['path'].nil? }
               else
                 finders.select { |_f, c| c['path'].nil? }
               end

          fs.each do |finder_name, config|
            klass = config['class'] ? config['class'] : finder_name

            next unless klass.to_sym == finder_class

            configs[slug] ||= {}
            configs[slug][finder_name] = config
          end
        end

        configs
      end

      # @return [ Hash ]
      def self.versions_finders_configs
        return @versions_finders if @versions_finders

        @versions_finders = {}

        db_data.each do |slug, finders|
          finders.each do |finder_name, config|
            next unless config.key?('version')

            @versions_finders[slug] ||= {}
            @versions_finders[slug][finder_name] = config
          end
        end

        @versions_finders
      end

      # @param [ String ] slug
      # @return [ Constant ]
      def self.maybe_create_modudle(slug)
        # What about slugs such as js_composer which will be done as JsComposer, just like js-composer
        constant_name = classify_slug(slug)

        unless version_finder_module.constants.include?(constant_name)
          version_finder_module.const_set(constant_name, Module.new)
        end

        version_finder_module.const_get(constant_name)
      end

      def self.create_versions_finders
        versions_finders_configs.each do |slug, finders|
          # Kind of an issue here, module is created even if there is no valid classes
          # Could put the #maybe_ directly in the #send() BUT it would be checked everytime,
          # which is kind of a waste
          mod = maybe_create_modudle(slug)

          finders.each do |finder_class, config|
            klass = config['class'] ? config['class'] : finder_class

            # Instead of raising exceptions, skip unallowed/already defined finders
            # So that, when new DF configs are put in the .yml
            # users with old version of WPScan will still be able to scan blogs
            # when updating the DB but not the tool
            next if mod.constants.include?(finder_class.to_sym) ||
                    !ALLOWED_CLASSES.include?(klass.to_sym)

            version_finder_super_class(klass).create_child_class(mod, finder_class.to_sym, config)
          end
        end
      end

      # The idea here would be to check if the class exist in
      # the Finders::DynamicFinders::Plugins/Themes::klass or WpItemVersion::klass
      # and return the related constant when one has been found.
      #
      # So far, the Finders::DynamicFinders::WPItemVersion is enought
      # as nothing else is used
      #
      # @param [ String, Symbol ] klass
      # @return [ Constant ]
      def self.version_finder_super_class(klass)
        "WPScan::Finders::DynamicFinder::WpItemVersion::#{klass}".constantize
      end

      # @param [ Symbol ] sym
      def self.method_missing(sym)
        super unless sym =~ /\A(passive|aggressive)_(.*)_finder_configs\z/i

        finder_class = Regexp.last_match[2].camelize.to_sym

        raise "#{finder_class} is not allowed as a Dynamic Finder" unless ALLOWED_CLASSES.include?(finder_class)

        finder_configs(
          finder_class,
          Regexp.last_match[1] == 'aggressive'
        )
      end

      def self.respond_to_missing?(sym)
        sym =~ /\A(passive|aggressive)_(.*)_finder_configs\z/i
      end
    end
  end
end
