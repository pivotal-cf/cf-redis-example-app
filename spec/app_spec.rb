require 'spec_helper'
require 'json'

require 'app'

describe 'app' do

  def app
    Sinatra::Application.new
  end

  def without_vcap_services
    vcap_services = ENV.delete("VCAP_SERVICES")
    yield
    ENV.store("VCAP_SERVICES", vcap_services)
  end

  let(:path) { "/#{key}" }
  let(:key) { 'foo' }

  context 'when there is no redis instance bound' do
    it 'returns 500 INTERNAL SERVICE ERROR' do
      without_vcap_services do
        get path
        expect(last_response.status).to eq(500)
      end
    end

    it 'returns binding instructions' do
      without_vcap_services do
        get path
        expect(last_response.body).to match('You must bind a Redis service instance to this application.')
        expect(last_response.body).to match('You can run the following commands to create an instance and bind to it:')
        expect(last_response.body).to match('\$ cf create-service p-redis development redis-instance')
        expect(last_response.body).to match('\$ cf bind-service <app-name> redis-instance')
      end
    end
  end

  context 'when there is a redis instance bound' do
    before do
      ENV["VCAP_SERVICES"] ||= {
        'redis' => {
           'name' => 'redis',
           'label' => 'redis',
           'tags' => [
              'redis',
              'pivotal'
           ],
           'plan' => 'default',
           'credentials' => {
             'password' => REDIS.password,
             'host' => REDIS.host,
             'port' => REDIS.port
           }
        }
      }.to_json
    end

    describe 'PUT /:key' do
      context 'with data' do
        let(:payload) { { data: 'bar' } }

        it 'returns 201 CREATED' do
          put path, payload
          expect(last_response.status).to eq(201)
        end

        it 'returns "success"' do
          put path, payload
          expect(last_response.body).to match('success')
        end
      end

      context 'without data' do
        let(:payload) { nil }

        it 'returns 400 BAD REQUEST' do
          put path, payload
          expect(last_response.status).to eq(400)
        end

        it 'tells the user to send data' do
          put path, payload
          expect(last_response.body).to match('data field missing')
        end
      end
    end

    describe 'GET /:key' do
      context 'when the key does not exist' do
        let(:key) { 'nonexistant' }

        it 'returns 404 NOT FOUND' do
          get path
          expect(last_response.status).to eq(404)
        end

        it 'reports that the key is not present' do
          get path
          expect(last_response.body).to match('key not present')
        end
      end

      context 'when the key exists' do
        let(:value) { 'a value' }
        let(:payload) { { data: value } }

        before do
          put path, payload
        end

        it 'returns 200 OK' do
          get path
          expect(last_response.status).to eq(200)
        end

        it 'returns the value' do
          get path
          expect(last_response.body).to eq(value)
        end
      end
    end

    describe 'DELETE /:key' do
      context 'when the key does not exist' do
        let(:key) { 'nonexistant' }

        it 'returns 404 NOT FOUND' do
          delete path
          expect(last_response.status).to eq(404)
        end

        it 'reports that the key is not present' do
          delete path
          expect(last_response.body).to match('key not present')
        end
      end

      context 'when the key exists' do
        let(:value) { 'a value' }
        let(:payload) { { data: value } }

        before do
          put path, payload
        end

        it 'returns 200 OK' do
          delete path
          expect(last_response.status).to eq(200)
        end

        it 'returns success' do
          delete path
          expect(last_response.body).to eq('success')
        end

        it 'deletes the key' do
          delete path
          get path
          expect(last_response.status).to eq(404)
        end
      end
    end
  end
end
