require 'spec_helper'

describe WPScan::Finders::Plugins::BodyPattern do
  subject(:finder) { described_class.new(target) }
  let(:target)     { WPScan::Target.new(url) }
  let(:url)        { 'http://wp.lab/' }
  let(:fixtures)   { File.join(DYNAMIC_FINDERS_FIXTURES, 'plugin_version') }

  def plugin(slug)
    WPScan::Plugin.new(slug, target)
  end

  describe '#passive' do
    after do
      stub_request(:get, target.url).to_return(body: body)

      found = finder.passive

      expect(found).to match_array @expected
      expect(found.first.found_by).to eql 'Header Pattern (Passive Detection)' unless found.empty?
    end

    context 'when no matches' do
      let(:body) { '' }

      it 'returns an empty array' do
        @expected = []
      end
    end

    context 'when matches (well currently not)' do
      # before { expect(target).to receive(:content_dir).and_return('wp-content') }

      let(:body) { File.read(File.join(fixtures, 'body_pattern_passive_all.html')) }

      it 'returns the expected plugins' do
        @expected = []

        WPScan::DB::DynamicPluginFinders.passive_body_pattern_finder_configs.each_key do |slug|
          @expected << plugin(slug)
        end
      end
    end
  end

  describe '#aggressive' do
    xit
  end
end
