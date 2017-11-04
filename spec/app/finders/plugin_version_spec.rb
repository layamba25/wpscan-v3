require 'spec_helper'

describe WPScan::Finders::PluginVersion::Base do
  subject(:plugin_version) { described_class.new(plugin) }
  let(:plugin)             { WPScan::Plugin.new(slug, target) }
  let(:target)             { WPScan::Target.new('http://wp.lab/') }
  let(:slug)               { 'spec' }
  let(:default_finders)    { %w[Readme] }

  describe '#finders' do
    after do
      expect(target).to receive(:content_dir).and_return('wp-content')
      expect(plugin_version.finders.map { |f| f.class.to_s.demodulize }).to include(*@expected)
    end

    context 'when no related specific finders' do
      it 'contains the default finders' do
        @expected = default_finders
      end
    end

    # TODO: Remove the finders from the Dynamic Method ? (They don't seem to be loaded here anymore)
    #
    # Dynamic Version Finders are not tested here, they are in
    # - spec/app/finders/plugins/comments_specs (nothing needs to be changed)
    # - spec/app/finders/controllers/enumeration_spec (nothing needs to be changed)
    # - spec/fixtures/db/dynamic_finders.yml (add/update the pattern in there)
    # - spec/fixtures/finders/plugins/comments/found.html (add/update the HTML comments there)
    #
    # Note: versions detected by the dynamic finders are currently not tested (TODO)
    #
    # However, they should be included in the below if they have both dynamic and specific finders
    # like for the revslider plugin
    context 'when specific finders' do
      {
        'sitepress-multilingual-cms' => %w[VersionParameter], # MetaGenerator],
        # 'w3-total-cache' => %w[Headers], # Comment],
        'LayerSlider' => %w[TranslationFile],
        # 'revslider' => %w[ReleaseLog Comment]
      }.each do |plugin_slug, specific_finders|
        context "when #{plugin_slug} plugin" do
          let(:slug) { plugin_slug }

          it 'contains the expected finders' do
            @expected = default_finders + specific_finders
          end
        end
      end
    end
  end
end
