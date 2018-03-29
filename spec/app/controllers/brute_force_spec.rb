require 'spec_helper'

describe WPScan::Controller::BruteForce do
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
      expect(controller.cli_options.map(&:to_sym)).to eq %i[passwords usernames]
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

  describe '#output_error' do
    xit
  end

  describe '#run' do
    context 'when no --passwords is supplied' do
      it 'does not run the brute forcer' do
        expect(controller.run).to eql nil
      end
    end
  end

  describe '#brute_force' do
    xit
  end
end
