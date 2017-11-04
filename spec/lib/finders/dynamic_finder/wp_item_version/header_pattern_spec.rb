require 'spec_helper'

describe WPScan::Finders::DynamicFinder::WpItemVersion::HeaderPattern do
  module WPScan
    module Finders
      module PluginVersion
        # Needed to be able to test the below
        module Rspec
        end
      end
    end
  end

  subject(:finder)       { finder_class.new(plugin) }
  let(:plugin)           { WPScan::Plugin.new('spec', target) }
  let(:target)           { WPScan::Target.new('http://wp.lab/') }
  let(:fixtures)         { File.join(DYNAMIC_FINDERS_FIXTURES, 'wp_item_version', 'header_pattern') }
  let(:response_headers) { JSON.parse(File.read(File.join(fixtures, 'headers.json'))) }

  let(:finder_module) { WPScan::Finders::PluginVersion::Rspec }
  let(:finder_class)  { WPScan::Finders::PluginVersion::Rspec::HeaderPattern }
  let(:finder_config) { { 'header' => 'Location' } }

  before { described_class.create_child_class(finder_module, :HeaderPattern, finder_config) }
  after  { finder_module.send(:remove_const, :HeaderPattern) }

  describe '.create_child_class' do
    context 'when no PATH and CONFIDENCE' do
      it 'contains the expected constants to their default values' do
        # Doesn't work, dunno why
        # expect(finder_module.const_get(:Comment)).to be_a described_class
        # expect(finder_class.is_a?(described_class)).to eql true
        # expect(finder_class).to be_a described_class

        expect(finder_class::HEADER).to eql finder_config['header']

        expect(finder_class::PATTERN).to eql nil
        expect(finder_class::CONFIDENCE).to eql 30
        expect(finder_class::PATH).to eql nil
      end
    end

    context 'when CONFIDENCE' do
      let(:finder_config) { super().merge('confidence' => 50) }

      it 'contains the expected constants' do
        expect(finder_class::HEADER).to eql finder_config['header']
        expect(finder_class::CONFIDENCE).to eql finder_config['confidence']

        expect(finder_class::PATTERN).to eql nil
        expect(finder_class::PATH).to eql nil
      end
    end

    context 'when PATH' do
      let(:finder_config) { super().merge('path' => 'index.php') }

      it 'contains the expected constants' do
        expect(finder_class::HEADER).to eql finder_config['header']
        expect(finder_class::PATH).to eql finder_config['path']

        expect(finder_class::PATTERN).to eql nil
        expect(finder_class::CONFIDENCE).to eql 30
      end
    end

    context 'when PATTERN' do
      let(:finder_config) { super().merge('pattern' => /Version: (?<v>[\d\.]+)/i) }

      it 'contains the expected constants' do
        expect(finder_class::HEADER).to eql finder_config['header']
        expect(finder_class::PATTERN).to eql finder_config['pattern']

        expect(finder_class::PATH).to eql nil
        expect(finder_class::CONFIDENCE).to eql 30
      end
    end
  end

  describe '#passive' do
    before { stub_request(:get, target.url).to_return(headers: response_headers) }

    let(:finder_config) { super().merge('pattern' => /report\.php\?ver=(?<v>[\d\.^&]+)\&/i) }

    it 'returns the expected version' do
      version = finder.passive

      expect(version).to eq WPScan::Version.new(
        '4.16.53',
        confidence: 30,
        found_by: 'Header Pattern (Passive Detection)'
      )
      expect(version.interesting_entries).to eql ["#{target.url}, Match: 'report.php?ver=4.16.53&'"]
    end
  end

  describe '#aggressive' do
    let(:wp_content) { 'wp-content' }
    let(:finder_config) do
      super().merge('path' => 'index.php',
                    'pattern' => /report\.php\?ver=(?<v>[\d\.^&]+)\&/i)
    end

    before do
      expect(target).to receive(:content_dir).at_least(1).and_return(wp_content)
      stub_request(:get, plugin.url('index.php')).to_return(headers: response_headers)
    end

    it 'returns the expected version' do
      version = finder.aggressive

      expect(version).to eq WPScan::Version.new(
        '4.16.53',
        confidence: 30,
        found_by: 'Header Pattern (Aggressive Detection)'
      )
      expect(version.interesting_entries).to eql ["#{plugin.url('index.php')}, Match: 'report.php?ver=4.16.53&'"]
    end
  end
end
