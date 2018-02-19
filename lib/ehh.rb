require "ehh/version"
require "rack"

module Ehh
  class Router
    def initialize
      @routes = []
    end

    def register(method, pattern, handler)
      @routes << Route.new(method, pattern, handler)
    end

    def recognize(env)
      @routes.find { |route| route.match?(env) }
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
        named_captures = env["PATH_INFO"].match(@pattern).named_captures
        unless named_captures.empty?
          named_captures.each do |param, value|
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
