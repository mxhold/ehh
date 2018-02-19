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
    error_message = <<EOS
Locked file has changed!

Expected digest: #{expected_digest}
  Actual digest: #{actual_digest}

This exception is being raised to remind you that whenever you update this file:

  #{target_filepath}

you should consider the implications for this file:

  #{caller_file}

Once you've considered the implications, re-lock by pasting:

  lock_file("#{relative_target_filepath}", "#{actual_digest}", __FILE__, __LINE__)

on #{caller_file}:#{caller_line}
EOS
    fail RuntimeError, error_message
  end
end
