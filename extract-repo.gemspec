require_relative "version"

Gem::Specification.new do |spec|
  spec.name = "extract-repo"
  spec.version = ExtractRepoVersion::VERSION
  spec.authors = ["Miles Georgi"]
  spec.email = ["azimux@gmail.com"]

  spec.summary = "Extract code from one repository into a new repository, preserving history of the extracted files."
  spec.homepage = "https://github.com/foobara/extract-repo"

  # Equivalent to SPDX License Expression: Apache-2.0 OR MIT
  spec.license = "Apache-2.0 OR MIT"
  spec.licenses = ["Apache-2.0", "MIT"]

  spec.required_ruby_version = ExtractRepoVersion::MINIMUM_RUBY_VERSION

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir[
    "bin/extract-repo",
    "boot/**/*",
    "boot.rb",
    "lib/**/*",
    "src/**/*",
    "LICENSE*.txt",
    "README.md",
    "CHANGELOG.md"
  ]

  spec.bindir = "bin"
  spec.executables = ["extract-repo"]

  spec.add_dependency "foobara", "~> 0.0.102"
  spec.add_dependency "foobara-sh-cli-connector", "~> 0.0.1"

  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
