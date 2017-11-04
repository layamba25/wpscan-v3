require 'spec_helper'

describe WPScan::Finders::DynamicFinder::WpItemVersion::Xpath do
  module WPScan
    module Finders
      module PluginVersion
        # Needed to be able to test the below
        module Rspec
        end
      end
    end
  end

  subject(:finder)    { finder_class.new(plugin) }
  let(:plugin)        { WPScan::Plugin.new('spec', target) }
  let(:target)        { WPScan::Target.new('http://wp.lab/') }
  let(:fixtures)      { File.join(DYNAMIC_FINDERS_FIXTURES, 'wp_item_version', 'xpath') }
  let(:response_body) { File.read(File.join(fixtures, 'index.html')) }

  let(:finder_module) { WPScan::Finders::PluginVersion::Rspec }
  let(:finder_class)  { WPScan::Finders::PluginVersion::Rspec::Xpath }
  let(:finder_config) { { 'xpath' => "//div/h3[@class='version-number']" } }

  before { described_class.create_child_class(finder_module, :Xpath, finder_config) }
  after  { finder_module.send(:remove_const, :Xpath) }

  describe '.create_child_class' do
    let(:default_pattern) { /\A(?<v>[\d\.]+)/i }

    context 'when no PATH and CONFIDENCE' do
      it 'contains the expected constants to their default values' do
        # Doesn't work, dunno why
        # expect(finder_module.const_get(:Comment)).to be_a described_class
        # expect(finder_class.is_a?(described_class)).to eql true
        # expect(finder_class).to be_a described_class

        expect(finder_class::XPATH).to eql finder_config['xpath']

        expect(finder_class::PATTERN).to eql default_pattern
        expect(finder_class::CONFIDENCE).to eql 50
        expect(finder_class::PATH).to eql nil
      end
    end

    context 'when CONFIDENCE' do
      let(:finder_config) { super().merge('confidence' => 30) }

      it 'contains the expected constants' do
        expect(finder_class::XPATH).to eql finder_config['xpath']
        expect(finder_class::CONFIDENCE).to eql finder_config['confidence']

        expect(finder_class::PATTERN).to eql default_pattern
        expect(finder_class::PATH).to eql nil
      end
    end

    context 'when PATH' do
      let(:finder_config) { super().merge('path' => 'file.txt') }

      it 'contains the expected constants' do
        expect(finder_class::XPATH).to eql finder_config['xpath']
        expect(finder_class::PATH).to eql finder_config['path']

        expect(finder_class::PATTERN).to eql default_pattern
        expect(finder_class::CONFIDENCE).to eql 50
      end
    end

    context 'when PATTERN' do
      let(:finder_config) { super().merge('pattern' => /Version: (?<v>[\d\.]+)/i) }

      it 'contains the expected constants' do
        expect(finder_class::XPATH).to eql finder_config['xpath']
        expect(finder_class::PATTERN).to eql finder_config['pattern']

        expect(finder_class::PATH).to eql nil
        expect(finder_class::CONFIDENCE).to eql 50
      end
    end
  end

  describe '#passive' do
    before { stub_request(:get, target.url).to_return(body: response_body) }

    it 'returns the expected version' do
      version = finder.passive

      expect(version).to eq WPScan::Version.new(
        '4.6.5',
        confidence: 50,
        found_by: 'Xpath (Passive Detection)'
      )
      expect(version.interesting_entries).to eql ["#{target.url}, Match: '4.6.5'"]
    end
  end

  describe '#aggressive' do
    let(:wp_content) { 'wp-content' }
    let(:finder_config) { super().merge('path' => 'log.html') }

    before do
      expect(target).to receive(:content_dir).at_least(1).and_return(wp_content)
      stub_request(:get, plugin.url('log.html')).to_return(body: response_body)
    end

    it 'returns the expected version' do
      version = finder.aggressive

      expect(version).to eq WPScan::Version.new(
        '4.6.5',
        confidence: 50,
        found_by: 'Comment (Aggressive Detection)'
      )
      expect(version.interesting_entries).to eql ["#{plugin.url('log.html')}, Match: '4.6.5'"]
    end
  end
end
