require "spec_helper"

RSpec.describe Ehh do
  it "has a version number" do
    expect(Ehh::VERSION).not_to be nil
  end

  describe "README example" do
    it "works" do
      lock_file("../config.ru", "dfeee297f7e1b2b276f81b6f49046c33", __FILE__, __LINE__)
      code_example = File.readlines(File.join(__dir__, "..", "config.ru"))[1..-2].join
      router = nil
      app = nil
      eval(code_example)

      request_env = Rack::MockRequest.env_for("/")
      root_response = app.call(request_env)
      expect(root_response).to eq([200, {}, ["Hello!\n"]])

      request_env = Rack::MockRequest.env_for(
        "/",
        {
          method: :post,
          input: "Hello, world",
          "CONTENT_TYPE" => "text/plain",
        },
      )
      status, headers, body = app.call(request_env)
      body = body.join
      expect(status).to eq(201)
      expect(headers).to eq({"Content-Type" => "text/plain; charset=utf-8"})
      expect(body).to match(%r(^http://example.org/#{UUID_PATTERN}$))

      request_env = Rack::MockRequest.env_for(body)
      status, headers, body = app.call(request_env)
      expect(status).to eq(200)
      expect(headers).to eq({"Content-Type" => "text/plain; charset=utf-8"})
      expect(body.join).to eq("Hello, world")
    end
  end
end
