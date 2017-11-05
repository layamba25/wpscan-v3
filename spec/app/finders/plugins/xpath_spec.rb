require 'spec_helper'

describe WPScan::Finders::Plugins::Xpath do
  subject(:finder) { described_class.new(target) }
  let(:target)     { WPScan::Target.new(url) }
  let(:url)        { 'http://wp.lab/' }
  let(:fixtures)   { File.join(DYNAMIC_FINDERS_FIXTURES, 'plugin_version') }

  describe '#passive' do
    before do
      stub_request(:get, target.url).to_return(body: File.read(File.join(fixtures, 'xpath_passive_all.html')))
      expect(target).to receive(:content_dir).at_least(1).and_return('wp-content')
    end

    it 'contains the plugins found from the #xpath_matches' do
      expect(finder.passive.map(&:slug)).to include(*WPScan::DB::DynamicPluginFinders.passive_xpath_finder_configs.keys)
    end
  end
end
