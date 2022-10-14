# frozen_string_literal: true

module SolidusKlaviyo
  class Tracker < SolidusTracking::Tracker
    class << self
      def from_config
        new
      end
    end

    def track(event)
      klaviyo.track_post({
        event: event.name,
        email: event.email,
        customer_properties: event.customer_properties,
        properties: event.properties,
        time: event.time,
      }.to_json)
    end

    private

    def klaviyo
      @klaviyo ||= Klaviyo::TrackIdentify
    end
  end
end
