require "ehh"
require "securerandom"
require "sqlite3"

module MyApp
  class Repo
    def initialize
      @db = SQLite3::Database.new("db.sqlite3")
    end

    def setup
      @db.execute("CREATE TABLE IF NOT EXISTS posts (id TEXT, body BLOB)")
      @db.execute("CREATE UNIQUE INDEX IF NOT EXISTS posts_id ON posts (id)")
    end

    def insert_post(id:, body:)
      @db.execute("INSERT INTO posts (id, body) VALUES (?, ?)", [id, body])
    end

    def fetch_post_body(id:)
      @db.get_first_value("SELECT body FROM posts WHERE id = ?", [id])
    end
  end

  class Root
    def call(context, request, response)
      response.status = 200
      response.set_header "Content-Type", "text/plain; charset=utf-8"
      response.write "curl #{request.base_url} -X POST -H 'Content-Type: text/plain' -d 'Hello, world!'\n"
    end
  end

  module Posts
    class Create
      def call(context, request, response)
        post_id = SecureRandom.uuid

        context.repo.insert_post(id: post_id, body: request.body.read)

        response.status = 201
        response.set_header "Content-Type", "text/plain; charset=utf-8"
        response.write "#{request.base_url}/#{post_id}"
      end
    end

    class Show
      def call(context, request, response)
        post_id = request.params.fetch("post_id")

        post_body = context.repo.fetch_post_body(id: post_id)

        if post_body
          response.status = 200
          response.set_header "Content-Type", "text/plain; charset=utf-8"
          response.write post_body
        else
          response.status = 404
          response.set_header "Content-Type", "text/plain; charset=utf-8"
          response.write "Post not found\n"
        end
      end
    end
  end
end

repo = MyApp::Repo.new
repo.setup

router = Ehh::Router.new(context: { repo: repo })
router.register("GET", %r(^/$), MyApp::Root.new)
router.register("POST", %r(^/$), MyApp::Posts::Create.new)
router.register("GET", %r(^/(?<post_id>[0-9a-f\-]+$)), MyApp::Posts::Show.new)

app = Ehh::Application.build(router: router)

run app
