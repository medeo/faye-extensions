require 'net/http'

module FayeExtensions

  class Broadcast

    attr_reader :channel

    def initialize(channel)
      @channel = channel
    end

    def send(message)
      message = sign_message(message)
      request = Net::HTTP::Post.new(uri.path)
      request.set_form_data(:message => message.to_json)
      http.request(request)
    end

    private

      def sign_message(message)
        { :channel => channel,
          :data    => message,
          :ext     => message_ext }
      end

      def message_ext
        { TOKEN_KEY => AuthToken.assign_token(SERVER_ID, channel).as_json }
      end

      def http
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.use_ssl = true
          http.cert_store = OpenSSL::X509::Store.new
          http.cert_store.set_default_paths
          http.cert_store.add_file(Rails.root.join('lib/certs/ca-bundle.crt').to_s)
        end
        http
      end

      def uri
        @uri ||= URI.parse(FayeExtensions.broadcast_url)
      end

  end

end
