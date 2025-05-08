ENV["FOOBARA_ENV"] ||= "development"

if File.exist?("#{__dir__}/../Gemfile")
  # Seems we are not being ran as a gem executable. Let's bundle since we might be in a test or
  # we might be pointed at via path: or some other similar situation.
  ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)
  require "bundler/setup"
end
