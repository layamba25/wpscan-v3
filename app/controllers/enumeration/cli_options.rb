module WPScan
  module Controller
    # Enumeration CLI Options
    class Enumeration < CMSScanner::Controller::Base
      def cli_options
        cli_enum_choices + cli_plugins_opts + cli_themes_opts +
          cli_timthumbs_opts + cli_config_backups_opts + cli_db_exports_opts +
          cli_medias_opts + cli_users_opts
      end

      # @return [ Array<OptParseValidator::OptBase> ]
      # rubocop:disable Metrics/MethodLength
      def cli_enum_choices
        [
          OptMultiChoices.new(
            ['--enumerate [OPTS]', '-e', 'Enumeration Process'],
            choices: {
              vp:  OptBoolean.new(['--vulnerable-plugins']),
              ap:  OptBoolean.new(['--all-plugins']),
              p:   OptBoolean.new(['--plugins']),
              vt:  OptBoolean.new(['--vulnerable-themes']),
              at:  OptBoolean.new(['--all-themes']),
              t:   OptBoolean.new(['--themes']),
              tt:  OptBoolean.new(['--timthumbs']),
              cb:  OptBoolean.new(['--config-backups']),
              dbe: OptBoolean.new(['--db-exports']),
              u:   OptIntegerRange.new(['--users', 'User IDs range. e.g: u1-5'], value_if_empty: '1-10'),
              m:   OptIntegerRange.new(['--medias', 'Media IDs range. e.g m1-15'], value_if_empty: '1-100')
            },
            value_if_empty: 'vp,vt,tt,cb,dbe,u,m',
            incompatible: [%i[vp ap p], %i[vt at t]],
            default: { all_plugins: true, config_backups: true }
          ),
          OptRegexp.new(
            [
              '--exclude-content-based REGEXP_OR_STRING',
              'Exclude all responses having their body matching (case insensitive) during parts of the enumeration.',
              'Regexp delimiters are not required.'
            ], options: Regexp::IGNORECASE
          )
        ]
      end
      # rubocop:enable Metrics/MethodLength

      # @return [ Array<OptParseValidator::OptBase> ]
      def cli_plugins_opts
        [
          OptSmartList.new(['--plugins-list LIST', 'List of plugins to enumerate']),
          OptChoice.new(
            ['--plugins-detection MODE',
             'Use the supplied mode to enumerate Plugins, instead of the global (--detection-mode) mode.'],
            choices: %w[mixed passive aggressive], normalize: :to_sym, default: :passive
          ),
          OptBoolean.new(
            ['--plugins-version-all',
             'Check all the plugins version locations according to the choosen mode (--detection-mode, ' \
             '--plugins-detection and --plugins-version-detection)']
          ),
          OptChoice.new(
            ['--plugins-version-detection MODE',
             'Use the supplied mode to check plugins versions instead of the --detection-mode ' \
             'or --plugins-detection modes.'],
            choices: %w[mixed passive aggressive], normalize: :to_sym, default: :mixed
          )
        ]
      end

      # @return [ Array<OptParseValidator::OptBase> ]
      def cli_themes_opts
        [
          OptSmartList.new(['--themes-list LIST', 'List of themes to enumerate']),
          OptChoice.new(
            ['--themes-detection MODE',
             'Use the supplied mode to enumerate Themes, instead of the global (--detection-mode) mode.'],
            choices: %w[mixed passive aggressive], normalize: :to_sym
          ),
          OptBoolean.new(
            ['--themes-version-all',
             'Check all the themes version locations according to the choosen mode (--detection-mode, ' \
             '--themes-detection and --themes-version-detection)']
          ),
          OptChoice.new(
            ['--themes-version-detection MODE',
             'Use the supplied mode to check themes versions instead of the --detection-mode ' \
             'or --themes-detection modes.'],
            choices: %w[mixed passive aggressive], normalize: :to_sym
          )
        ]
      end

      # @return [ Array<OptParseValidator::OptBase> ]
      def cli_timthumbs_opts
        [
          OptFilePath.new(
            ['--timthumbs-list FILE-PATH', 'List of timthumbs\' location to use'],
            exists: true, default: File.join(DB_DIR, 'timthumbs-v3.txt')
          ),
          OptChoice.new(
            ['--timthumbs-detection MODE',
             'Use the supplied mode to enumerate Timthumbs, instead of the global (--detection-mode) mode.'],
            choices: %w[mixed passive aggressive], normalize: :to_sym
          )
        ]
      end

      # @return [ Array<OptParseValidator::OptBase> ]
      def cli_config_backups_opts
        [
          OptFilePath.new(
            ['--config-backups-list FILE-PATH', 'List of config backups\' filenames to use'],
            exists: true, default: File.join(DB_DIR, 'config_backups.txt')
          ),
          OptChoice.new(
            ['--config-backups-detection MODE',
             'Use the supplied mode to enumerate Config Backups, instead of the global (--detection-mode) mode.'],
            choices: %w[mixed passive aggressive], normalize: :to_sym
          )
        ]
      end

      # @return [ Array<OptParseValidator::OptBase> ]
      def cli_db_exports_opts
        [
          OptFilePath.new(
            ['--db-exports-list FILE-PATH', 'List of DB exports\' paths to use'],
            exists: true, default: File.join(DB_DIR, 'db_exports.txt')
          ),
          OptChoice.new(
            ['--db-exports-detection MODE',
             'Use the supplied mode to enumerate DB Exports, instead of the global (--detection-mode) mode.'],
            choices: %w[mixed passive aggressive], normalize: :to_sym
          )
        ]
      end

      # @return [ Array<OptParseValidator::OptBase> ]
      def cli_medias_opts
        [
          OptChoice.new(
            ['--medias-detection MODE',
             'Use the supplied mode to enumerate Medias, instead of the global (--detection-mode) mode.'],
            choices: %w[mixed passive aggressive], normalize: :to_sym
          )
        ]
      end

      # @return [ Array<OptParseValidator::OptBase> ]
      def cli_users_opts
        [
          OptSmartList.new(
            ['--users-list LIST',
             'List of users to check during the users enumeration from the Login Error Messages']
          ),
          OptChoice.new(
            ['--users-detection MODE',
             'Use the supplied mode to enumerate Users, instead of the global (--detection-mode) mode.'],
            choices: %w[mixed passive aggressive], normalize: :to_sym
          )
        ]
      end
    end
  end
end
