require "spec_helper"

RSpec.describe Ehh do
  it "has a version number" do
    expect(Ehh::VERSION).not_to be nil
  end

  it "works as specified in the README" do
    lock_file("../app.rb", "0d8539d88204705105124bb1e6041cfe", __FILE__, __LINE__)
    code_example = File.readlines(File.join(__dir__, "..", "app.rb"))[2..23].join
    router = nil
    app = nil
    eval(code_example)

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
