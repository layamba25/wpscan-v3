require 'spec_helper'

describe WPScan::DB::DynamicPluginFinders do
  subject(:dynamic_finders) { described_class }

  describe '.finders_configs' do
    context 'when the given class is not allowed' do
      it 'returns an empty hash' do
        expect(subject.finder_configs('aaaa')).to eql({})
      end
    end

    context 'when the given class is allowed' do
      context 'when aggressive argument is false' do
        it 'returns only the configs w/o a path parameter' do
          configs = subject.finder_configs(:Xpath)

          expect(configs.keys).to include('wordpress-mobile-pack', 'shareaholic')
          expect(configs.keys).to_not include('revslider')

          expect(configs['sitepress-multilingual-cms']['MetaGenerator']['pattern']).to be_a Regexp
          expect(configs['sitepress-multilingual-cms']['MetaGenerator']['version']).to eql true
        end
      end

      context 'when aggressive argument is true' do
        it 'returns only the configs with a path parameter' do
          configs = subject.finder_configs(:Xpath, true)

          expect(configs.keys).to include('revslider')
          expect(configs.keys).to_not include('shareaholic')
        end
      end
    end
  end

  describe '.versions_finders_configs' do
    # Just test a sample here
    its('versions_finders_configs.keys') { should include('shareaholic') }
    its('versions_finders_configs.keys') { should_not include('wordpress-mobile-pack') }
  end

  describe '.maybe_create_module' do
    xit
  end

  describe '.create_versions_finders' do
    # handled and tested in spec/lib/finders/dynamic_finders/plugin_version_spec
  end

  describe '.version_finder_super_class' do
    let(:mod) { WPScan::Finders::PluginVersion::RspecFailure }

    context 'when a class already exist' do
      module WPScan
        module Finders
          module PluginVersion
            module RspecFailure
              class Comment
              end
            end
          end
        end
      end

      it 'raises an error' do
        expect { subject.version_finder_super_class(mod, :Comment) }
          .to raise_error('WPScan::Finders::PluginVersion::RspecFailure has already a Comment class')
      end
    end

    context 'when a class is not allowed' do
      it 'raises an error' do
        expect { subject.version_finder_super_class(mod, :NotAllowed) }
          .to raise_error('NotAllowed is not allowed as a Dynamic Finder')
      end
    end
  end

  describe '.method_missing' do
    context 'when the method matches a valid call' do
      its('passive_comment_finder_configs.keys') { should include('addthis') }
      its('passive_comment_finder_configs.keys') { should_not include('shareaholic') }

      its('passive_xpath_finder_configs.keys') { should include('shareaholic') }
      its('passive_xpath_finder_configs.keys') { should_not include('revslider') }
      its('aggressive_xpath_finder_configs.keys') { should_not include('wordpress-mobile-pack') }
      its('aggressive_xpath_finder_configs.keys') { should include('revslider') }
    end

    context 'when the method does not match a valid call' do
      it 'raises an error' do
        expect { subject.aaa }.to raise_error(NoMethodError)
      end
    end
  end
end
