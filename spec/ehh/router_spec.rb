require "spec_helper"

RSpec.describe Ehh::Router do
  describe "#register" do
    it "registers the route" do
      router = Ehh::Router.new
      router.register("GET", %r(/$), -> (_request, response) { })
    end
  end

  describe "#call" do
    it "calls the handler from the first route that matches" do
      router = Ehh::Router.new
      router.register("POST", %r(^/$), -> (_request, response) do
        response.status = 101
      end)
      router.register("GET", %r(^/$), -> (_request, response) do
        response.status = 102
      end)
      router.register("GET", %r(^/$), -> (_request, response) do
        response.status = 103
      end)

      request_env = Rack::MockRequest.env_for("/")
      status, _headers, _body = router.call(request_env)
      expect(status).to eq(102)
    end

    it "sets params from the named captures" do
      router = Ehh::Router.new
      router.register("GET", %r(^/users/(?<username>\w+)$), -> (request, response) do
        response.write request.params["username"]
      end)

      request_env = Rack::MockRequest.env_for("/users/max")
      _status, _headers, body = router.call(request_env)
      body_string = ""
      body.each { |s| body_string << s }
      expect(body_string).to eq("max")
    end

    it "calls the default handler if no route matches" do
      router = Ehh::Router.new
      request_env = Rack::MockRequest.env_for("/")
      status, _headers, body = router.call(request_env)
      body_string = ""
      body.each { |s| body_string << s }
      expect(status).to eq(404)
      expect(body_string).to eq("404 Not Found\n")
    end
  end

  describe "#default_handler=" do
    it "allows specifying the handler that is used if no route matches" do
      router = Ehh::Router.new
      router.default_handler = -> (request, response) do
        response.status = 404
        response.write "#{request.path} not found!"
      end
      request_env = Rack::MockRequest.env_for("/foo")
      status, _headers, body = router.call(request_env)
      body_string = ""
      body.each { |s| body_string << s }
      expect(status).to eq(404)
      expect(body_string).to eq("/foo not found!")
    end
  end
end
