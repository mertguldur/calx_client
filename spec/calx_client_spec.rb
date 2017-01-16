require 'spec_helper'
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
        with(query: hash_including('date' => date.to_s)).
        to_return(body: response_body.to_json, status: 200, headers: headers)
    end

    it 'returns the events' do
      expect(subject.events(user_id, date: date)).to eq(response_body)
    end
  end

  describe '#event' do
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

  context 'error cases' do
    let(:event_id) { 1 }

    before do
      stub_request(:get, "#{host}/events/#{event_id}").
        to_return(body: '', status: status_code, headers: headers)
    end

    context 'HTTP no content' do
      let(:status_code) { 204 }

      it 'is no content' do
        expect(subject.event(event_id)).to eq(:no_content)
      end
    end

    context 'HTTP unauthorized' do
      let(:status_code) { 401 }

      it 'raises AuthenticationError' do
        expect do
          subject.event(event_id)
        end.to raise_error(CalX::AuthenticationError)
      end
    end

    context 'HTTP client error' do
      let(:status_code) { 400 }

      it 'raises ClientError' do
        expect do
          subject.event(event_id)
        end.to raise_error(CalX::ClientError)
      end
    end

    context 'HTTP server error' do
      let(:status_code) { 500 }

      it 'raises ServerError' do
        expect do
          subject.event(event_id)
        end.to raise_error(CalX::ServerError)
      end
    end

    context 'HTTP client error' do
      let(:status_code) { 308 }

      it 'raises Error' do
        expect do
          subject.event(event_id)
        end.to raise_error(CalX::Error)
      end
    end
  end
end
