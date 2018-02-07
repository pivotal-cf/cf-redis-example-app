require 'spec_helper'

describe CF::App::Environment do
  let(:variables) { [ variable ] }

  let(:vcap_services) do {
    'user-provided'=> [
      {
        'credentials'=> {
          'username'=> 'leroy-jenkins',
          'password'=> 'hunter2'
        },
        'label'=> 'test-label',
        'name'=> 'test-name',
      }
    ]
  }
  end

  let(:env) { { "VCAP_SERVICES" => JSON.dump(vcap_services) } }

  describe 'searching by label' do
    let(:env_var_config) do {
      'name' => 'USERNAME',
      'method' => 'label',
      'parameter' => 'test-label',
      'key' => 'username'
    }
    end

    it 'sets the USERNAME environment variable' do
      described_class.new(env).set!(env_var_config)
      expect(env['USERNAME']).to eq 'leroy-jenkins'
    end
  end

  describe 'searching by name' do
    let(:env_var_config) do {
      'name' => 'PASSWORD',
      'method' => 'name',
      'parameter' => 'test-name',
      'key' => 'password'
    }
    end

    it 'sets the PASSWORD environment variable' do
      described_class.new(env).set!(env_var_config)
      expect(env['PASSWORD']).to eq 'hunter2'
    end
  end

  describe 'error handling' do
    describe "key values must exist" do
      shared_examples_for "a method that requires keys that exist" do
        context 'when the value is not found' do
          let(:env_var_config) do {
            'name' => 'PASSWORD',
            'method' => 'name',
            'parameter' => 'test-name',
            'key' => 'password'
          }
          end

          before do
            env_var_config[key] = 'missing'
          end

          it 'raises a key not found error' do
            expect { described_class.new(env).set!(env_var_config) }.to raise_error(KeyError)
          end
        end
      end

      context "when method is missing" do
        let(:key) { 'method' }
        it_behaves_like "a method that requires keys that exist"
      end

      context "when key is missing" do
        let(:key) { 'key' }
        it_behaves_like "a method that requires keys that exist"
      end

      context "when parameter is missing" do
        let(:key) { 'parameter' }
        it_behaves_like "a method that requires keys that exist"
      end
    end
  end

  describe "keys must exist" do
    shared_examples_for "a method that requires keys" do
      context 'when the value is not found' do
        let(:env_var_config) do {
          'name' => 'PASSWORD',
          'method' => 'name',
          'parameter' => 'test-name',
          'key' => 'password'
        }
        end

        before do
          env_var_config.delete(key)
        end

        it 'raises a key not found error' do
          expect { described_class.new(env).set!(env_var_config) }.to raise_error(KeyError, "key not found: \"#{key}\"")
        end
      end
    end

    context "when method is missing" do
      let(:key) { 'method' }
      it_behaves_like "a method that requires keys"
    end

    context "when key is missing" do
      let(:key) { 'key' }
      it_behaves_like "a method that requires keys"
    end

    context "when parameter is missing" do
      let(:key) { 'parameter' }
      it_behaves_like "a method that requires keys"
    end
  end
end
