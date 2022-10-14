# frozen_string_literal: true

RSpec.describe SolidusKlaviyo::Tracker do
  describe '.from_config' do
    it 'returns a tracker with the configured API key' do
      allow(SolidusKlaviyo.configuration).to receive(:api_key).and_return('test_key')

      tracker = described_class.from_config

      expect(tracker.is_a?(SolidusKlaviyo::Tracker))
    end
  end

  describe '#track' do
    before(:each) do
      # Configure global Klaviyo client allows Klaviyo::TrackIdentify
      # to exist.
      SolidusKlaviyo.configure do |config|
        config.api_key = 'secret123'
      end
    end

    it 'tracks the event through the Klaviyo API' do
      klaviyo_client = stub_klaviyo_client

      time = Time.zone.now

      expect(klaviyo_client).to receive(:track_post).with({
        event: 'Started Checkout',
        email: 'jdoe@example.com',
        customer_properties: { '$email' => 'jdoe@example.com' },
        properties: { 'foo' => 'bar' },
        time: time,
      }.to_json)

      event = instance_double(
        SolidusTracking::Event::StartedCheckout,
        name: 'Started Checkout',
        email: 'jdoe@example.com',
        customer_properties: { '$email' => 'jdoe@example.com' },
        properties: { 'foo' => 'bar' },
        time: time,
      )

      event_tracker = described_class.new(api_key: 'test_key')
      allow(event_tracker).to receive(:klaviyo).and_return(klaviyo_client)
      event_tracker.track(event)
    end
  end

  private

  def stub_klaviyo_client
    class_double(Klaviyo::TrackIdentify)
  end
end
