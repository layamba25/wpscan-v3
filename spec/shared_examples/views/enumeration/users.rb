shared_examples 'App::Views::Enumeration::Users' do
  let(:view)  { 'users' }
  let(:user)  { CMSScanner::User }

  describe 'users' do
    context 'when no users found' do
      let(:expected_view) { File.join(view, 'none_found') }

      it 'outputs the expected string' do
        @tpl_vars = tpl_vars.merge(users: [])
      end
    end

    context 'when users found' do
      let(:expected_view) { File.join(view, 'users') }

      xit 'outputs the expected string' do
      end
    end
  end
end
