require 'spec_helper'

describe WPScan::Finders::WpVersion::EmojiSettings do
  subject(:finder) { described_class.new(target) }
  let(:target)     { WPScan::Target.new(url).extend(CMSScanner::Target::Server::Apache) }
  let(:url)        { 'http://ex.lo/' }
  let(:fixtures)   { File.join(FINDERS_FIXTURES, 'wp_version', 'emoji_settings') }

  describe '#passive' do
    before { stub_request(:get, target.url).to_return(body: body) }

    context 'when not found' do
      let(:body) { '' }

      its(:passive) { should be_nil }
    end

    context 'when found' do
      after do
        version = finder.passive

        expect(version).to eql @expected
        expect(version.interesting_entries).to eql @expected.interesting_entries if @expected
      end

      context 'when invalid number' do
        let(:body) { File.read(File.join(fixtures, 'invalid.html')) }

        it 'returns nil' do
          @expected = nil
        end
      end

      context 'when valid number' do
        let(:body) { File.read(File.join(fixtures, 'valid.html')) }

        it 'returns the expected version' do
          @expected = WPScan::WpVersion.new(
            '3.8.1',
            confidence: 70,
            found_by: 'Emoji Settings (Passive Detection)',
            interesting_entries: [
              "http://ex.lo/, Match: 'wp-includes\\/js\\/wp-emoji-release.min.js?ver=3.8.1'"
            ]
          )
        end
      end
    end
  end
end
