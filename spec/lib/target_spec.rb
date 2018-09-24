require 'spec_helper'

describe WPScan::Target do
  subject(:target) { described_class.new(url) }
  let(:url)        { 'http://ex.lo' }

  it_behaves_like WPScan::Target::Platform::WordPress

  describe 'xmlrpc' do
    before do
      allow(target).to receive(:sub_dir)

      expect(target).to receive(:interesting_findings).and_return(interesting_findings)
    end

    context 'when no interesting_findings' do
      let(:interesting_findings) { [] }

      its(:xmlrpc) { should be_nil }
    end

    context 'when interesting_findings' do
      let(:interesting_findings) { ['aa', CMSScanner::RobotsTxt.new(target.url)] }

      context 'when no XMLRPC' do
        its(:xmlrpc) { should be_nil }
      end

      context 'when XMLRPC' do
        let(:xmlrpc) { WPScan::XMLRPC.new(target.url('xmlrpc.php')) }
        let(:interesting_findings) { super() << xmlrpc }

        its(:xmlrpc) { should eq xmlrpc }
      end
    end
  end

  %i[wp_version main_theme plugins themes timthumbs config_backups medias users].each do |method|
    describe "##{method}" do
      before do
        return_value = %i[wp_version main_theme].include?(method) ? false : []

        expect(WPScan::Finders.const_get("#{method.to_s.camelize}::Base"))
          .to receive(:find).with(target, opts).and_return(return_value)
      end

      after { target.send(method, opts) }

      let(:opts) { {} }

      context 'when no options' do
        it 'calls the finder with the correct arguments' do
          # handled by before hook
        end
      end

      context 'when options' do
        let(:opts) { { mode: :passive, somthing: 'k' } }

        it 'calls the finder with the corect arguments' do
          # handled by before hook
        end
      end

      context 'when called multiple times' do
        it 'calls the finder only once' do
          target.send(method, opts)
        end
      end
    end
  end

  describe '#vulnerable?' do
    context 'when all attributes are nil' do
      it { should_not be_vulnerable }
    end

    context 'when wp_version is not found' do
      before { target.instance_variable_set(:@wp_version, false) }

      it { should_not be_vulnerable }
    end

    context 'when wp_version found' do
      context 'when not vulnerable' do
        before { target.instance_variable_set(:@wp_version, WPScan::WpVersion.new('4.4')) }

        it { should_not be_vulnerable }
      end

      context 'when vulnerable' do
        before { target.instance_variable_set(:@wp_version, WPScan::WpVersion.new('3.8.1')) }

        it { should be_vulnerable }
      end
    end

    context 'when config_backups' do
      before do
        target.instance_variable_set(:@config_backups, [WPScan::ConfigBackup.new(target.url('/a-file-url'))])
      end

      it { should be_vulnerable }
    end

    context 'when users' do
      before do
        target.instance_variable_set(:@users, [CMSScanner::User.new('u1'), CMSScanner::User.new('u2')])
      end

      context 'when no passwords' do
        it { should_not be_vulnerable }
      end

      context 'when at least one password has been found' do
        before { target.users[1].password = 'owned' }

        it { should be_vulnerable }
      end
    end
  end
end
