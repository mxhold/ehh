require "spec_helper"

RSpec.describe Ehh do
  it "has a version number" do
    expect(Ehh::VERSION).not_to be nil
  end

  describe "README example" do
    it "works" do
      lock_file("../config.ru", "5c4126b8337ed9ce13662d0bdd22f48b", __FILE__, __LINE__)
      code_example = File.readlines(File.join(__dir__, "..", "config.ru"))[1..-2].join
      app = nil
      eval(code_example)

      mock_request(app, "/") do |status, headers, body|
        expect(status).to eq(200)
        expect(headers["Content-Type"]).to eq("text/plain; charset=utf-8")
        expect(body).to eq("Hello!\n")
      end

      request_opts = {
          method: :post,
          input: "Hello, world",
          "CONTENT_TYPE" => "text/plain",
      }
      created_post_url = nil

      mock_request(app, "/", request_opts) do |status, headers, body|
        expect(status).to eq(201)
        expect(headers["Content-Type"]).to eq("text/plain; charset=utf-8")
        expect(body).to match(%r(^http://example.org/#{UUID_PATTERN}$))
        created_post_url = body
      end

      mock_request(app, created_post_url) do |status, headers, body|
        expect(status).to eq(200)
        expect(headers["Content-Type"]).to eq("text/plain; charset=utf-8")
        expect(body).to eq("Hello, world")
      end
    end
  end
end
