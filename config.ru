require "ehh"
require "securerandom"
require "sqlite3"

UUID_PATTERN = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

database_file = "db.sqlite3"
$db = SQLite3::Database.new(database_file)
$db.execute("CREATE TABLE IF NOT EXISTS posts (id TEXT, body BLOB)")
$db.execute("CREATE UNIQUE INDEX IF NOT EXISTS posts_id ON posts (id)")

module MyApp
  class Root
    def call(request)
      [200, {}, ["Hello!\n"]]
    end
  end

  module Posts
    class Create
      def call(request)
        post_id = SecureRandom.uuid
        post_body = request.body.read

        $db.execute(
          "INSERT INTO posts (id, body) VALUES (?, ?)",
          [post_id, post_body]
        )
        [201, {"Content-Type" => "text/plain; charset=utf-8"}, [request.base_url, "/", post_id]]
      end
    end

    class Show
      def call(request)
        post_id = request.params.fetch("post_id")

        post_body = $db.execute("SELECT body FROM posts WHERE id = ?", [post_id]).flatten.first

        if post_body
          [200, {"Content-Type" => "text/plain; charset=utf-8"}, [post_body]]
        else
          [404, {"Content-Type" => "text/plain; charset=utf-8"}, ["Post not found\n"]]
        end
      end
    end
  end
end

router = Ehh::Router.new

router.register("GET", %r(^/$), MyApp::Root.new)
router.register("POST", %r(^/$), MyApp::Posts::Create.new)
router.register("GET", %r(^/(?<post_id>#{UUID_PATTERN}$)), MyApp::Posts::Show.new)

app = Ehh::Application.build(router: router)

run app
