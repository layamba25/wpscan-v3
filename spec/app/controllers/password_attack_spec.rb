require 'spec_helper'

describe WPScan::Controller::PasswordAttack do
  subject(:controller) { described_class.new }
  let(:target_url)     { 'http://ex.lo/' }
  let(:parsed_options) { rspec_parsed_options(cli_args) }
  let(:cli_args)       { "--url #{target_url}" }

  before do
    WPScan::Browser.reset
    described_class.parsed_options = parsed_options
  end

  describe '#cli_options' do
    its(:cli_options) { should_not be_empty }
    its(:cli_options) { should be_a Array }

    it 'contains to correct options' do
      expect(controller.cli_options.map(&:to_sym))
        .to eq(%i[passwords usernames multicall_max_passwords password_attack])
    end
  end

  describe '#users' do
    context 'when no --usernames' do
      it 'calles target.users' do
        expect(controller.target).to receive(:users)
        controller.users
      end
    end

    context 'when --usernames' do
      let(:cli_args) { "#{super()} --usernames admin,editor" }

      it 'returns an array with the users' do
        expected = %w[admin editor].reduce([]) do |a, e|
          a << CMSScanner::User.new(e)
        end

        expect(controller.users).to eql expected
      end
    end
  end

  describe '#passwords' do
    xit
  end

  describe '#run' do
    context 'when no --passwords is supplied' do
      it 'does not run the attacker' do
        expect(controller.run).to eql nil
      end
    end
  end

  describe '#attacker' do
    before do
      expect(controller.target).to receive(:xmlrpc).and_return(xmlrpc)
    end

    context 'when --password-attack provided' do
      let(:xmlrpc)   { WPScan::XMLRPC.new("#{target_url}/xmlrpc.php") }
      let(:cli_args) { "#{super()} --password-attack #{attack}" }

      context 'when wp-login' do
        let(:attack) { 'wp-login' }

        it 'returns the correct object' do
          expect(controller.attacker).to be_a WPScan::Finders::Passwords::WpLogin
          expect(controller.attacker.target).to be_a WPScan::Target
        end
      end

      context 'when xmlrpc' do
        let(:attack) { 'xmlrpc' }

        it 'returns the correct object' do
          expect(controller.attacker).to be_a WPScan::Finders::Passwords::XMLRPC
          expect(controller.attacker.target).to be_a WPScan::XMLRPC
        end
      end

      context 'when xmlrpc-multicall' do
        let(:attack) { 'xmlrpc-multicall' }

        it 'returns the correct object' do
          expect(controller.attacker).to be_a WPScan::Finders::Passwords::XMLRPCMulticall
          expect(controller.attacker.target).to be_a WPScan::XMLRPC
        end
      end
    end

    context 'when automatic detection' do
      context 'when xmlrpc not found' do
        let(:xmlrpc) { nil }

        it 'returns the WpLogin' do
          expect(controller.attacker).to be_a WPScan::Finders::Passwords::WpLogin
          expect(controller.attacker.target).to be_a WPScan::Target
        end
      end

      context 'when xmlrpc not enabled' do
        let(:xmlrpc) { WPScan::XMLRPC.new("#{target_url}/xmlrpc.php") }

        it 'returns the WpLogin' do
          expect(xmlrpc).to receive(:enabled?).and_return(false)

          expect(controller.attacker).to be_a WPScan::Finders::Passwords::WpLogin
          expect(controller.attacker.target).to be_a WPScan::Target
        end
      end

      context 'when xmlrpc enabled' do
        let(:xmlrpc) { WPScan::XMLRPC.new("#{target_url}/xmlrpc.php") }

        before { expect(xmlrpc).to receive(:enabled?).and_return(true) }

        context 'when wp.getUsersBlogs methods not available' do
          it 'returns the WpLogin' do
            expect(xmlrpc).to receive(:available_methods).and_return(%w[m1 m2])

            expect(controller.attacker).to be_a WPScan::Finders::Passwords::WpLogin
            expect(controller.attacker.target).to be_a WPScan::Target
          end
        end

        context 'when wp.getUsersBlogs method evailable' do
          before { expect(xmlrpc).to receive(:available_methods).and_return(%w[wp.getUsersBlogs m2]) }

          context 'when WP version not found' do
            it 'returns the XMLRPC' do
              expect(controller.target).to receive(:wp_version).and_return(false)

              expect(controller.attacker).to be_a WPScan::Finders::Passwords::XMLRPC
              expect(controller.attacker.target).to be_a WPScan::XMLRPC
            end
          end

          context 'when WP version found' do
            before { expect(controller.target).to receive(:wp_version).and_return(wp_version) }

            context 'when WP < 4.4' do
              let(:wp_version) { WPScan::WpVersion.new('3.8.1') }

              it 'returns the XMLRPCMulticall' do
                expect(controller.attacker).to be_a WPScan::Finders::Passwords::XMLRPCMulticall
                expect(controller.attacker.target).to be_a WPScan::XMLRPC
              end
            end

            context 'when WP >= 4.4' do
              let(:wp_version) { WPScan::WpVersion.new('4.4') }

              it 'returns the XMLRPC' do
                expect(controller.attacker).to be_a WPScan::Finders::Passwords::XMLRPC
                expect(controller.attacker.target).to be_a WPScan::XMLRPC
              end
            end
          end
        end
      end
    end
  end
end
