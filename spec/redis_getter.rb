require 'rack/test'

RSpec.shared_examples "redis get endpoint" do
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