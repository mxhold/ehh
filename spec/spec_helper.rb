require "bundler/setup"
require "ehh"
require "digest"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def lock_file(relative_target_filepath, expected_digest, caller_file, caller_line)
  target_filepath = File.expand_path(
    File.join(caller_file, "..", relative_target_filepath)
  )
  actual_digest = Digest::MD5.file(target_filepath)
  unless actual_digest == expected_digest
    target_file_relative_to_pwd = Pathname.new(target_filepath)
      .relative_path_from(Pathname.new(Dir.pwd)).to_s

    caller_file_relative_to_pwd = Pathname.new(caller_file)
      .relative_path_from(Pathname.new(Dir.pwd)).to_s

    error_message = <<EOS
Locked file has changed!

Expected digest: #{expected_digest}
  Actual digest: #{actual_digest}

This exception is being raised to remind you that whenever you update this file:

  #{target_file_relative_to_pwd}

you should consider the implications for this file:

  #{caller_file_relative_to_pwd}

Once you've considered the implications, re-lock by running:

  sed -i '' 's/#{expected_digest}/#{actual_digest}/' #{caller_file_relative_to_pwd}

EOS
    fail RuntimeError, error_message
  end
end

def mock_request(app, *opts)
  request_env = Rack::MockRequest.env_for(*opts)
  status, headers, body = app.call(request_env)
  body_string = ""
  body.each { |s| body_string << s }
  yield(status, headers, body_string)
end

