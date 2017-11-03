require 'spec_helper'

describe WPScan::DB::DynamicPluginFinders do
  subject(:dynamic_finders) { described_class }

  describe '.finders_configs' do
    context 'when the given class is not allowed' do
      it 'returns an empty hash' do
        expect(subject.finder_configs('aaaa')).to eql({})
      end

      context 'when the given class is allowed' do
        context 'when aggressive argument is false' do
          it 'returns only the configs w/o a path parameter' do
            configs = subject.finder_configs('Comment')

            expect(configs.keys).to include('wp-super-cache', 'rspec-failure')
            # TODO: when there is one with a path
            expect(configs.keys).to_not include('shareaholic')

            expect(configs['rspec-failure']['Comment']['pattern']).to be_a Regexp
            expect(configs['rspec-failure']['Comment']['version']).to eql true
          end
        end

        context 'when aggressive argument is true' do
          it 'returns only the configs with a path parameter' do
            # TODO
          end
        end
      end
    end
  end

  describe '.versions_finders_configs' do
    # TODO: add some from other Finder class when there are
    its('versions_finders_configs.keys') { should include('rspec-failure') }
    its('versions_finders_configs.keys') { should_not include('wp-super-cache') }
  end

  describe '.maybe_create_module' do
    xit
  end

  describe '.create_version_finders' do
    xit
  end

  describe '.method_missing' do
    context 'when the method matches a valid call' do
      its('passive_comment_finder_configs.keys') { should include('wp-super-cache') }
      its('passive_comment_finder_configs.keys') { should_not include('shareaholic') }

      its('aggressive_comment_finder_configs.keys') { should_not include('wp-super-cache') }
      # its('aggressive_comment_finder_configs.keys') { should include('??') }
    end

    context 'when the method does not match a valid call' do
      it 'raises an error' do
        expect { subject.aaa }.to raise_error(NoMethodError)
      end
    end
  end
end
