require "spec_helper"

RSpec.describe Ehh::Application do
  describe ".build" do
    it "returns an app that delegates calls to the router" do
      router = -> (env) do
        [200, {}, [env["PATH_INFO"]]]
      end
      app = Ehh::Application.build(router: router)
      request_env = Rack::MockRequest.env_for("/foo")
      response = app.call(request_env)

      expect(response).to eq([200, {}, ["/foo"]])
    end

    it "forces UTF8 encoding (for certain content types)" do
      router = -> (env) do
        body = Rack::Request.new(env).body.read
        [200, {}, [body]]
      end
      app = Ehh::Application.build(router: router)
      request_options = {
        method: :post,
        input: "Hello",
        "CONTENT_TYPE" => "text/plain",
      }
      request_env = Rack::MockRequest.env_for("/foo", request_options)
      _status, _headers, body = app.call(request_env)
      expect(body[0].encoding).to eq(Encoding::UTF_8)
    end
  end
end
