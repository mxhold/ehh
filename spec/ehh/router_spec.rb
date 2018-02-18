require "spec_helper"

RSpec.describe Ehh::Router do
  describe "#register" do
    it "registers the route" do
      router = Ehh::Router.new
      router.register("GET", %r(/$), -> (_) { [200, {}, [""]] })
    end
  end

  describe "#recognize" do
    it "returns the first registered route that matches both method and path pattern" do
      router = Ehh::Router.new
      router.register("POST", %r(/), -> (_) { [1, {}, ["should not match (wrong method)"]] })
      router.register("GET", %r(/), -> (_) { [2, {}, [""]] })
      router.register("GET", %r(/), -> (_) { [3, {}, ["should not match (earlier route matches)"]] })

      request_env = {"REQUEST_METHOD" => "GET", "PATH_INFO" => "/"}
      route = router.recognize(request_env)
      expect(route.call(request_env)).to eql([2, {}, [""]])
    end

    it "populates the request env with named captures" do
      router = Ehh::Router.new
      router.register("GET", %r(/users/(?<username>\w+)), -> (env) do
        [200, {}, [env["router.params"]["username"]]]
      end)

      request_env = {"REQUEST_METHOD" => "GET", "PATH_INFO" => "/users/max"}
      route = router.recognize(request_env)
      expect(route.call(request_env)).to eql([200, {}, ["max"]])
    end

    xit "returns the default route if none match"
  end
end
