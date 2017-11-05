require 'spec_helper'

def tested_class_constant(slug, finder_class)
  slug_class = slug.tr('-', '_').camelize

  "WPScan::Finders::PluginVersion::#{slug_class}::#{finder_class}".constantize
end

def stubbed_response_opts(fixture, finder_super_class)
  if finder_super_class == 'HeaderPattern'
    { headers: JSON.parse(File.read(fixture)) }
  else
    { body: File.read(fixture) }
  end
end

expected_all = YAML.safe_load(File.read(File.join(DYNAMIC_FINDERS_FIXTURES, 'plugin_version', 'expected.yml')))

WPScan::DB::DynamicPluginFinders.create_versions_finders

WPScan::DB::DynamicPluginFinders.versions_finders_configs.each do |slug, configs|
  configs.each do |finder_class, config|
    finder_super_class = config['class'] ? config['class'] : finder_class

    # next unless %w[Xpath Comment].include?(finder_super_class)

    describe tested_class_constant(slug, finder_class) do
      subject(:finder) { described_class.new(plugin) }
      let(:plugin)     { WPScan::Plugin.new(slug, target) }
      let(:target)     { WPScan::Target.new('http://wp.lab/') }
      let(:fixtures)   { File.join(DYNAMIC_FINDERS_FIXTURES, 'plugin_version') }

      let(:expected)   { expected_all[slug][finder_class] }

      let(:stubbed_response) { { body: '' } }

      describe '#passive' do
        before do
          stub_request(:get, target.url).to_return(stubbed_response)

          expect(target).to receive(:content_dir).at_least(1).and_return('wp-content')
        end

        if config['path']
          context 'when PATH' do
            it 'returns nil' do
              expect(finder.passive).to eql nil
            end
          end
        else
          context 'when no PATH' do
            let(:stubbed_response) do
              stubbed_response_opts(File.join(fixtures, "#{finder_super_class.underscore}_passive_all.html"),
                                    finder_super_class)
            end

            it 'returns the expected version from the homepage' do
              version = finder.passive

              expect(version.number).to eql expected['number']
              expect(version.found_by).to eql expected['found_by']
            end
          end
        end
      end

      describe '#aggressive' do
        let(:fixtures) { File.join(super(), slug.tr('-', '_'), finder_class.underscore) }

        before do
          expect(target).to receive(:content_dir).at_least(1).and_return('wp-content')
          # stub_request(:get, /.*/)
          stub_request(:get, plugin.url(config['path'])).to_return(stubbed_response)
        end

        if config['path']
          context 'when the version is detected' do
            let(:stubbed_response) do
              stubbed_response_opts(File.join(fixtures, config['path']), finder_super_class)
            end

            it 'returns the expected version' do
              version = finder.aggressive

              expect(version.number).to eql expected['number']
              expect(version.found_by).to eql expected['found_by']
            end
          end

          context 'when the version is not detected' do
            # TODO: Maybe a no_version.ext file in the fixtures dir to make
            # sure the pattern doesn't match some junk ?
            it 'returns nil' do
              expect(finder.aggressive).to eql nil
            end
          end
        else
          it 'returns nil' do
            expect(finder.aggressive).to eql nil
          end
        end
      end
    end
  end
end
