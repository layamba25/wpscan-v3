require 'spec_helper'

describe WPScan::Finders::Plugins::Xpath do
  subject(:finder)   { described_class.new(target) }
  let(:target)       { WPScan::Target.new(url) }
  let(:url)          { 'http://wp.lab/' }
  let(:fixtures)     { File.join(DYNAMIC_FINDERS_FIXTURES, 'plugin_version') }

  let(:expected_all) { df_expected_all['plugins'] }
  let(:default_confidence) { 70 }

  describe '#passive' do
    before do
      stub_request(:get, target.url)
        .to_return(body: File.read(File.join(fixtures, 'xpath_passive_all.html')))

      expect(target).to receive(:content_dir).at_least(1).and_return('wp-content')
    end

    it 'contains the expected plugins' do
      expected = []

      WPScan::DB::DynamicPluginFinders.passive_xpath_finder_configs.each do |slug, configs|
        configs.each_key do |finder_class|
          expected_finding_opts = expected_all[slug][finder_class]

          expected << WPScan::Plugin.new(
            slug,
            target,
            confidence: expected_finding_opts['confidence'] || default_confidence,
            found_by: expected_finding_opts['found_by']
          )
        end
      end

      expect(finder.passive).to eql expected
    end
  end

  describe '#aggressive' do
    before do
      @expected = []

      expect(target).to receive(:content_dir).at_least(1).and_return('wp-content')

      # Stubbing all requests to the different paths

      WPScan::DB::DynamicPluginFinders.aggressive_xpath_finder_configs.each do |slug, configs|
        configs.each do |finder_class, config|
          finder_super_class = config['class'] ? config['class'] : finder_class

          fixture               = File.join(fixtures, slug, finder_class.underscore, config['path'])
          stubbed_response      = df_stubbed_response(fixture, finder_super_class)
          path                  = "wp-content/plugins/#{slug}/#{config['path']}"
          expected_finding_opts = expected_all[slug][finder_class]

          stub_request(:get, target.url(path)).to_return(stubbed_response)

          @expected << WPScan::Plugin.new(
            slug,
            target,
            confidence: expected_finding_opts['confidence'] || default_confidence,
            found_by: expected_finding_opts['found_by']
          )
        end
      end
    end

    it 'retuns the expected plugins' do
      expect(finder.aggressive).to eql @expected
    end
  end
end
