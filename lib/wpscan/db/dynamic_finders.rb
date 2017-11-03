module WPScan
  module DB
    # Dynamic Finders
    class DynamicFinders
      ALLOWED_CLASSES = %w[Comment Xpath UrlsInPage].freeze

      # @return [ String ]
      def self.db_file
        @db_file ||= File.join(DB_DIR, 'dynamic_finders_01.yml')
      end

      # @return [ Hash ]
      def self.db_data
        @db_data ||= YAML.safe_load(File.read(db_file), [Regexp])
      end

      # @param [ String ] finder_class
      #
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

            next unless klass == finder_class

            configs[slug] ||= {}
            configs[slug][finder_name] = config # .dup ?
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
            @versions_finders[slug][finder_name] = config # .dup ?
          end
        end

        @versions_finders
      end

      # @param [ String ] slug
      # @return [ Constant ]
      def self.maybe_create_modudle(slug)
        # What about slugs such as js_composer which will be done as JsComposer, just like js-composer
        constant_name = slug.tr('-', '_').camelize.to_sym

        unless version_finder_module.constants.include?(constant_name)
          version_finder_module.const_set(constant_name, Module.new)
        end

        version_finder_module.const_get(constant_name)
      end

      def self.create_versions_finders
        versions_finders_configs.each do |slug, finders|
          # Issue here, module is created even if there is no valid classes
          # Could put the #maybe_ directly in the #send() BUT it would be checked everytime, which is kind of a waste
          mod = maybe_create_modudle(slug)

          finders.each do |finder_name, config|
            klass = config['class'] ? config['class'] : finder_name

            next unless ALLOWED_CLASSES.include?(klass) # or raise something ?

            send("create_#{klass.underscore}_finder".to_sym, mod, finder_name, config)
          end
        end
      end

      # @param [ Constant ] mod
      # @param [ String ] finder_name
      # @param [ Hash ] config
      def self.create_xpath_finder(mod, finder_name, config)
        mod.const_set(
          finder_name.to_sym, Class.new(Finders::FinderChild) do
            const_set(:PATH, config['path'])
            const_set(:XPATH, config['xpath'])
            const_set(:PATTERN, config['pattern'] || /\A(?<version>[\d\.]+)/i)
            const_set(:CONFIDENCE, config['confidence'] || 50)
          end
        )
      end

      # @param [ Constant ] mod
      # @param [ String ] finder_name
      # @param [ Hash ] config
      def self.create_comment_finder(mod, finder_name, config)
        mod.const_set(
          finder_name.to_sym, Class.new(Finders::FinderChild) do
            const_set(:PATH, config['path'])
            const_set(:PATTERN, config['pattern'])
            const_set(:CONFIDENCE, config['confidence'] || 30)
          end
        )
      end

      # @param [ Symbol ] sym
      def self.method_missing(sym)
        super unless sym =~ /\A(passive|aggressive)_(.*)_finder_configs\z/i

        finder_class = Regexp.last_match[2].camelize

        # TODO: better error
        raise StandardError, "#{finder_class} not allowed" unless ALLOWED_CLASSES.include?(finder_class)

        finder_configs(
          finder_class,
          Regexp.last_match[1] == 'aggressive'
        )
      end

      def self.respond_to_missing?(sym)
        # TODO
      end
    end
  end
end
