require 'spec_helper'

describe WPScan::Finders::Plugins::Comment do
  subject(:finder) { described_class.new(target) }
  let(:target)     { WPScan::Target.new(url) }
  let(:url)        { 'http://wp.lab/' }
  let(:fixtures)   { File.join(FINDERS_FIXTURES, 'plugins', 'comment') }

  def plugin(slug)
    # found_by and confidence not considered even though they should be
    WPScan::Plugin.new(slug, target) # , found_by: 'Comment (Passive Detection)', confidence: 50)
  end

  describe '#passive' do
    after do
      stub_request(:get, target.url).to_return(body: File.read(File.join(fixtures, file)))
      expect(finder.passive(opts)).to match_array @expected
    end

    let(:opts) { {} }

    context 'when none found' do
      let(:file) { 'none.html' }

      it 'returns an empty array' do
        @expected = []
      end
    end

    context 'when found' do
      before { expect(target).to receive(:content_dir).and_return('wp-content') }

      let(:file) { 'found.html' }
      let(:unique_expected) do
        expected = []

        WPScan::DB::DynamicPluginFinders.passive_comment_finder_configs.each_key do |slug|
          expected << plugin(slug)
        end

        expected
      end

      context 'when no opts[:unique]' do
        it 'returns the array w/o duplicate (:unique is true by default)' do
          @expected = unique_expected
        end
      end

      context 'when opts[:unique] = false' do
        let(:opts) { { unique: false } }

        it 'returns the array with all plugins, including those detected more than once' do
          @expected = unique_expected

          # Adds the plugins detected more than once (due to pattern variations)
          %w[
            all-in-one-seo-pack enhanced-links google-analytics-for-wordpress google-analytics-for-wordpress
            kontera-official nginx-helper
            optin-monster revslider w3-total-cache
            wordpress-seo wordpress-seo wow-analytics wow-analytics wow-analytics
            wp-piwik wp-piwik wp-piwik wp-spamfree
          ].each do |p|
            @expected << plugin(p)
          end
        end
      end
    end
  end
end
