require 'spec_helper'

# Not sure it's a good idea to have this here
module WPScan
  module Finders
    module DynamicFinder
      module WpItemVersion
        module Rspec
          # Spec class to have a custom PATTERN
          class Comment < WPScan::Finders::DynamicFinder::WpItemVersion::Comment
            PATH = nil
            PATTERN = /some version: (?<v>[\d\.]+)/i
            CONFIDENCE = 50
          end
        end
      end
    end
  end
end

describe WPScan::Finders::DynamicFinder::WpItemVersion::Rspec::Comment do
  subject(:finder)    { described_class.new(plugin) }
  let(:plugin)        { WPScan::Plugin.new('spec', target) }
  let(:target)        { WPScan::Target.new('http://wp.lab/') }
  let(:fixtures)      { File.join(DYNAMIC_FINDERS_FIXTURES, 'wp_item_version', 'comment') }
  let(:response_body) { File.read(File.join(fixtures, 'index.html')) }

  describe '#passive, #find' do
    before { stub_request(:get, target.url).to_return(body: response_body) }

    it 'returns the expected version' do
      version = finder.passive

      expect(version).to eql WPScan::Version.new(
        '1.5',
        confidence: 50,
        found_by: 'Comment (Passive Detection)',
        interesting_entries: ["#{target.url}, Match: 'Some version: 1.5'"]
      )
    end
  end

  describe '#aggressive, #find' do
    before do
      described_class.send(:remove_const, :PATH)
      described_class.const_set(:PATH, 'index.php')

      stub_request(:get, target.url).to_return(body: response_body)
      stub_request(:get, plugin.url('index.php')).to_return(body: response_body)
    end

    it 'returns the expected version' do
      version = finder.aggressive

      expect(version).to eql WPScan::Version.new(
        '1.5',
        confidence: 50,
        found_by: 'Comment (Aggressive Detection)',
        interesting_entries: ["#{plugin.url('index.php')}, Match: 'Some version: 1.5'"]
      )
    end
  end
end
