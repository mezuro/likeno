require 'spec_helper'
require 'yaml'

describe Likeno do
  context 'initial configuration' do
    describe 'config' do
      it 'should return the default configuration' do
        expect(Likeno.config).to eq({})
      end
    end
  end

  context 'creating custom configuration' do
    let(:config) { { 'address' => 'http://localhost.address' } }

    describe 'configure' do
      after :each do
        Likeno.configure {}
      end

      it 'should set the address' do
        Likeno.configure config
        expect(Likeno.config[:address]).to eq(config['address'])
      end
    end

    describe 'configure_with' do
      let(:yml) { 'filename.yml' }
      context 'with an existent YAML' do
        after :each do
          Likeno.configure {}
        end

        before do
          Psych.expects(:load_file).with(yml).returns config
        end

        it 'should set the config' do
          Likeno.configure_with(yml)

          expect(Likeno.config[:address]).to eq(config['address'])
        end
      end

      context 'with an inexistent YAML' do
        before do
          Psych.expects(:load_file).with(yml).raises(Errno::ENOENT)
        end

        it 'should keep the defaults' do
          expect { Likeno.configure_with(yml) }.to raise_error(Errno::ENOENT, /YAML configuration file couldn't be found\./)
        end
      end

      context 'with an invalid YAML' do
        before do
          Psych.expects(:load_file).with(yml).raises(Psych::Exception)
        end

        it 'should keep the defaults' do
          expect { Likeno.configure_with(yml) }.to raise_error(Psych::Exception, /YAML configuration file contains invalid syntax\./)
        end
      end
    end
  end
end
