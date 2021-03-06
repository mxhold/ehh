require "ehh/version"
require "rack"
require "rack/utf8_sanitizer"

module Ehh
  class Router
    attr_writer :default_handler
    def initialize(context: {})
      @routes = []
      @default_handler = -> (_context, request, response) do
        response.status = 404
        response.set_header "Content-Type", "text/plain; charset=utf-8"
        response.write "404 Not Found\n"
      end
      unless context.empty?
        @context = Struct.new(*context.keys).new(*context.values)
      end
    end

    def register(method, pattern, handler)
      @routes << Route.new(method, pattern, handler)
    end

    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new
      _recognize(request).call(@context, request, response)
      response.finish
    end

    def _recognize(request)
      @routes.find { |route| route.match?(request) } || @default_handler
    end

    class Route
      def initialize(method, pattern, handler)
        @method = method
        @pattern = pattern
        @handler = handler
      end

      def match?(request)
        request.request_method == @method && request.path_info.match?(@pattern)
      end

      def call(context, request, response)
        _set_params!(request)
        @handler.call(context, request, response)
      end

      def _set_params!(request)
        unless @pattern.named_captures.empty?
          request.path_info.match(@pattern).named_captures.each do |param, value|
            request.update_param(param, value)
          end
        end
      end
    end
  end

  module Application
    def self.build(router:)
      Rack::Builder.app do
        use Rack::UTF8Sanitizer
        run router
      end
    end
  end
end
