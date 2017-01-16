require 'calx_client'
require 'api-auth'
require 'webmock/rspec'

describe CalX::Client do
  let(:host) { 'http://localhost:3000/api/v1' }
  let(:headers) { { 'Content-Type' => 'application/json' } }

  subject { described_class.new('test_tenant', '12345') }

  describe '#authorize' do
    let(:user_id) { '1' }
    let(:tenant_id) { '1' }
    let(:response_body) { { 'user_id' => user_id, 'tenant_id' => tenant_id } }

    before do
      stub_request(:post, "#{host}/app_authorization_requests").
        with(body: { user_id: user_id }).
        to_return(body: response_body.to_json, status: 200, headers: headers)
    end

    it 'returns the app authorization request' do
      expect(subject.authorize(user_id)).to eq(response_body)
    end
  end

  describe '#events' do
    let(:user_id) { '1' }
    let(:date) { Date.today }
    let(:response_body) do
      { 'user_id' => user_id, 'event_id' => '1' }
    end

    before do
      stub_request(:get, "#{host}/users/#{user_id}/events").
        with(query: hash_including({ 'date' => date.to_s })).
        to_return(body: response_body.to_json, status: 200, headers: headers)
    end

    it 'returns the events' do
      expect(subject.events(user_id, date: date)).to eq(response_body)
    end
  end

  describe '#events' do
    let(:event_id) { '1' }
    let(:response_body) do
      { 'event_id' => event_id }
    end

    before do
      stub_request(:get, "#{host}/events/#{event_id}").
        to_return(body: response_body.to_json, status: 200, headers: headers)
    end

    it 'returns the event' do
      expect(subject.event(event_id)).to eq(response_body)
    end
  end

  describe '#create_event' do
    let(:user_id) { '1' }
    let(:event_id) { '1' }
    let(:event_params) do
      { 'title' => 'test' }
    end
    let(:response_body) do
      { 'event_id' => event_id, 'title' => 'test' }
    end

    before do
      stub_request(:post, "#{host}/users/#{user_id}/events").
        with(body: event_params).
        to_return(body: response_body.to_json, status: 200, headers: headers)
    end

    it 'returns the created event' do
      expect(subject.create_event(user_id, event_params)).to eq(response_body)
    end
  end

  describe '#update_event' do
    let(:event_id) { '1' }
    let(:event_params) do
      { 'title' => 'test' }
    end
    let(:response_body) do
      { 'event_id' => event_id, 'title' => 'test' }
    end

    before do
      stub_request(:put, "#{host}/events/#{event_id}").
        with(body: event_params).
        to_return(body: response_body.to_json, status: 200, headers: headers)
    end

    it 'returns the updated event' do
      expect(subject.update_event(event_id, event_params)).to eq(response_body)
    end
  end

  describe '#delete_event' do
    let(:event_id) { '1' }
    let(:response_body) do
      { 'event_id' => event_id, 'title' => 'test' }
    end

    before do
      stub_request(:delete, "#{host}/events/#{event_id}").
        to_return(body: response_body.to_json, status: 200, headers: headers)
    end

    it 'returns the deleted event' do
      expect(subject.delete_event(event_id)).to eq(response_body)
    end
  end
end
