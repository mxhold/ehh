require "ehh/version"
require "rack"

module Ehh
  class Router
    attr_writer :default_handler
    def initialize
      @routes = []
      @default_handler = -> (env) { [404, {}, ["404 Not Found\n"]] }
    end

    def register(method, pattern, handler)
      @routes << Route.new(method, pattern, handler)
    end

    def recognize(env)
      @routes.find { |route| route.match?(env) } || @default_handler
    end

    class Route
      def initialize(method, pattern, handler)
        @method = method
        @pattern = pattern
        @handler = handler
      end

      def match?(env)
        env["REQUEST_METHOD"] == @method && env["PATH_INFO"].match?(@pattern)
      end

      def call(env)
        _set_params!(env)
        @handler.call(env)
      end

      def _set_params!(env)
        unless @pattern.named_captures.empty?
          env["PATH_INFO"].match(@pattern).named_captures.each do |param, value|
            env["router.params"] ||= {}
            env["router.params"][param] = value
          end
        end
      end
    end
  end

  class Application
    def initialize(router:)
      @router = router
    end

    def call(env)
      @router.recognize(env).call(env)
    end
  end
end
