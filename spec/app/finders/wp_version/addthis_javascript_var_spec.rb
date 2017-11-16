require 'spec_helper'

describe WPScan::Finders::WpVersion::AddthisJavascriptVar do
  subject(:finder) { described_class.new(target) }
  let(:target)     { WPScan::Target.new(url).extend(CMSScanner::Target::Server::Apache) }
  let(:url)        { 'http://ex.lo/' }
  let(:fixtures)   { File.join(FINDERS_FIXTURES, 'wp_version', 'addthis_javascript_var') }

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
        let(:body) { File.read(File.join(fixtures, 'new_js.html')) }
        let(:expected) do
          WPScan::WpVersion.new(
            '3.8.1',
            confidence: 70,
            found_by: 'Addthis Javascript Var (Passive Detection)',
            interesting_entries: [
              "http://ex.lo/, Match: 'wp_blog_version = \"3.8.1\";'"
            ]
          )
        end

        it 'returns the expected version' do
          @expected = expected
        end

        context 'when mobile pack format' do
          let(:body) { File.read(File.join(fixtures, 'old_js.html')) }

          it 'returns the expecetd version' do
            @expected = expected
          end
        end
      end
    end
  end
end
