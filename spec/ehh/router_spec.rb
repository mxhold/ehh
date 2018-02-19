require "spec_helper"

RSpec.describe Ehh::Router do
  describe "#register" do
    it "registers the route" do
      router = Ehh::Router.new
      router.register("GET", %r(/$), -> (_) { [200, {}, [""]] })
    end
  end

  describe "#call" do
    it "delegates to the handler from the first route that matches" do
      router = Ehh::Router.new
      router.register("POST", %r(^/$), -> (_) { [1, {}, ["should not match (wrong method)"]] })
      router.register("GET", %r(^/$), -> (_) { [2, {}, [""]] })
      router.register("GET", %r(^/$), -> (_) { [3, {}, ["should not match (earlier route matches)"]] })

      request_env = Rack::MockRequest.env_for("/")
      expect(router.call(request_env)).to eql([2, {}, [""]])
    end

    it "sets params from the named captures" do
      router = Ehh::Router.new
      router.register("GET", %r(^/users/(?<username>\w+)$), -> (request) do
        [200, {}, [request.params["username"]]]
      end)

      request_env = Rack::MockRequest.env_for("/users/max")
      expect(router.call(request_env)).to eql([200, {}, ["max"]])
    end

    it "calls the default handler if no route matches" do
      router = Ehh::Router.new
      request_env = Rack::MockRequest.env_for("/")
      expect(router.call(request_env)).to eql([404, {}, ["404 Not Found\n"]])
    end
  end

  describe "#default_handler=" do
    it "allows specifying the handler that is used if no route matches" do
      router = Ehh::Router.new
      router.default_handler = -> (request) do
        [404, {}, ["#{request.path} not found!"]]
      end
      request_env = Rack::MockRequest.env_for("/foo")
      expect(router.call(request_env)).to eql([404, {}, ["/foo not found!"]])
    end
  end
end
