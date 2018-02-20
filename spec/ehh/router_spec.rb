require "spec_helper"

RSpec.describe Ehh::Router do
  describe "#initialize" do
    it "takes an optional context hash to be provided to all handlers" do
      router = Ehh::Router.new(context: { foo: "bar" })
      router.register("GET", %r(.), -> (context, _request, response) do
        response.write(context.foo)
      end)
      mock_request(router, "/") do |_status, _headers, body|
        expect(body).to eql("bar")
      end
    end

    it "has a nil context if none provided" do
      router = Ehh::Router.new
      router.register("GET", %r(.), -> (context, _request, response) do
        response.write(context.nil?)
      end)
      mock_request(router, "/") do |_status, _headers, body|
        expect(body).to eql("true")
      end
    end
  end

  describe "#register" do
    it "registers the route" do
      router = Ehh::Router.new
      router.register("GET", %r(/$), -> (_context, _request, response) { })
    end
  end

  describe "#call" do
    it "calls the handler from the first route that matches method and pattern" do
      router = Ehh::Router.new
      router.register("POST", %r(^/foo$), -> (_context, _request, response) do
        response.status = 101
      end)
      router.register("GET", %r(^/bar$), -> (_context, _request, response) do
        response.status = 102
      end)
      router.register("GET", %r(^/foo$), -> (_context, _request, response) do
        response.status = 103
      end)
      router.register("GET", %r(^/foo$), -> (_context, _request, response) do
        response.status = 104
      end)

      mock_request(router, "/foo") do |status, _headers, _body|
        expect(status).to eq(103)
      end
    end

    it "sets params from the named captures" do
      router = Ehh::Router.new
      router.register("GET", %r(^/users/(?<username>\w+)$), -> (_context, request, response) do
        response.write request.params["username"]
      end)

      mock_request(router, "/users/max") do |_status, _headers, body|
        expect(body).to eq("max")
      end
    end

    it "calls the default handler if no route matches" do
      router = Ehh::Router.new

      mock_request(router, "/users/max") do |status, _headers, body|
        expect(status).to eq(404)
        expect(body).to eq("404 Not Found\n")
      end
    end
  end

  describe "#default_handler=" do
    it "allows specifying the handler that is used if no route matches" do
      router = Ehh::Router.new
      router.default_handler = -> (_context, request, response) do
        response.status = 404
        response.write "#{request.path} not found!"
      end

      mock_request(router, "/foo") do |status, _headers, body|
        expect(status).to eq(404)
        expect(body).to eq("/foo not found!")
      end
    end
  end
end
