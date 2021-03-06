require "spec_helper"

RSpec.describe "pastebin example" do
  describe "README example" do
    it "can GET /, POST /, and GET /:post_id" do
      pastebin_file = File.join(__dir__, "..", "..", "examples", "pastebin.ru")
      code_example = File.readlines(pastebin_file)[1..-2].join
      app = nil
      eval(code_example)

      mock_request(app, "/") do |status, headers, body|
        expect(status).to eq(200)
        expect(headers["Content-Type"]).to eq("text/plain; charset=utf-8")
        expect(body).to eq("curl http://example.org -X POST -H 'Content-Type: text/plain' -d 'Hello, world!'\n")
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
        expect(body).to match(%r(^http://example.org/[0-9a-f\-]+$))
        created_post_url = body
      end

      mock_request(app, created_post_url) do |status, headers, body|
        expect(status).to eq(200)
        expect(headers["Content-Type"]).to eq("text/plain; charset=utf-8")
        expect(body).to eq("Hello, world")
      end

      mock_request(app, "/abc123") do |status, headers, body|
        expect(status).to eq(404)
        expect(headers["Content-Type"]).to eq("text/plain; charset=utf-8")
        expect(body).to eq("Post not found\n")
      end
    end
  end
end
