module WPScan
  module DB
    # Fingerprints class
    class Fingerprints
      WP_FINGERPRINTS_PATH = File.join(DB_DIR, 'wp_fingerprints.json').freeze

      # @return the unique fingerprints in the data argument given
      def self.unique_fingerprints(data)
        unique_fingerprints = {}

        data.each do |file_path, fingerprints|
          fingerprints.each do |md5sum, versions|
            next unless versions.size == 1

            unique_fingerprints[file_path] ||= {}
            unique_fingerprints[file_path][md5sum] = versions
          end
        end

        unique_fingerprints
      end

      def self.wp_fingerprints
        @wp_fingerprints ||= read_json_file(WP_FINGERPRINTS_PATH)
      end

      def self.wp_unique_fingerprints
        @wp_unique_fingerprints ||= unique_fingerprints(wp_fingerprints)
      end
    end
  end
end
