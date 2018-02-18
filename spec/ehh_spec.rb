require "spec_helper"

RSpec.describe Ehh do
  it "has a version number" do
    expect(Ehh::VERSION).not_to be nil
  end

  it "works as specified in the README" do
    router = Ehh::Router.new

    router.register("GET", %r(/$), -> (_env) { [200, {}, ["Hello!\n"]] })
    router.register("GET", %r(/users/(?<username>\w+)), -> (env) do
      [200, {}, ["Hello, #{env["router.params"]["username"]}!\n"]]
    end)

    app = Ehh::Application.new(router: router)

    root_response = app.call({
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/",
    })
    expect(root_response).to eq([200, {}, ["Hello!\n"]])

    user_response = app.call({
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/users/max",
    })
    expect(user_response).to eq([200, {}, ["Hello, max!\n"]])
  end
end
