require "ehh"

module MyApp
  class Root
    def call(env)
      [200, {}, ["Hello!\n"]]
    end
  end

  module Users
    class Show
      def call(env)
        [200, {}, ["Hello, #{env["router.params"]["username"]}!\n"]]
      end
    end
  end
end

router = Ehh::Router.new

router.register("GET", %r(/$), MyApp::Root.new)
router.register("GET", %r(/users/(?<username>\w+)), MyApp::Users::Show.new)

app = Ehh::Application.new(router: router)
run app
