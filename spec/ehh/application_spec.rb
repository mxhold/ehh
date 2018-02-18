require "spec_helper"

RSpec.describe Ehh::Application do
  describe "#initialize" do
    it "requires a router" do
      expect do
        Ehh::Application.new
      end.to raise_error(ArgumentError)
    end
  end

  describe "#call" do
    it "uses router to recognize the route and dispatch" do
      router = instance_double("Ehh::Router")
      route = instance_double("Ehh::Router::Route")
      env = double
      response = double

      expect(router).to receive(:recognize).with(env).and_return(route)
      expect(route).to receive(:call).with(env).and_return(response)

      app = Ehh::Application.new(router: router)
      app.call(env)
    end
  end
end
