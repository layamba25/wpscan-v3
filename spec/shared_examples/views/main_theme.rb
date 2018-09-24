shared_examples 'App::Views::MainTheme' do
  let(:controller) { WPScan::Controller::MainTheme.new }
  let(:tpl_vars)   { { url: target_url } }
  let(:theme)      { WPScan::Theme.new(theme_name, target, found_by: 'rspec') }

  describe 'main_theme' do
    let(:view) { 'theme' }

    context 'when no theme found' do
      let(:expected_view) { 'not_found' }

      it 'outputs the expected string' do
        @tpl_vars = tpl_vars.merge(theme: nil)
      end
    end

    context 'when a theme found' do
      let(:theme_name) { 'test' }

      before do
        expect(target).to receive(:content_dir).at_least(1).and_return('wp-content')
        stub_request(:get, /.*/)
        stub_request(:get, /.*\.css\z/)
          .to_return(body: File.read(File.join(FIXTURES, 'models', 'theme', 'style.css')))
      end

      context 'when no verbose' do
        let(:expected_view) { 'no_verbose' }

        it 'outputs the expected string' do
          expect(theme).to receive(:version).at_least(1)

          @tpl_vars = tpl_vars.merge(theme: theme)
        end
      end

      context 'when verbose' do
        let(:expected_view) { 'verbose' }

        it 'outputs the expected string' do
          expect(theme).to receive(:version).at_least(1).and_return(WPScan::Version.new('3.2', found_by: 'style'))
          @tpl_vars = tpl_vars.merge(theme: theme, verbose: true)
        end
      end

      context 'when vulnerable' do
        let(:expected_view) { 'vulnerable' }
        let(:theme_name)    { 'dignitas-themes' }

        it 'outputs the expected string' do
          expect(theme).to receive(:version).at_least(1)
          @tpl_vars = tpl_vars.merge(theme: theme, verbose: true)
        end
      end
    end
  end
end
