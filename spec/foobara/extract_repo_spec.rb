require "English"
RSpec.describe Foobara::ExtractRepo do
  let(:repo_path) do
    "#{__dir__}/../fixtures/test_repo"
  end
  let(:output_dir) do
    # TODO: make this an input to ExtractRepo
    "#{Dir.home}/tmp/extract/test_repo"
  end

  def inflate_test_repo
    Dir.chdir(File.dirname(repo_path)) do
      # :nocov:
      unless Dir.exist?("extract_repo")
        `tar zxvf test_repo.tar.gz`
        unless $CHILD_STATUS.exitstatus == 0
          raise "Failed to inflate test repo"
        end
      end
      # :nocov:
    end
  end

  before do
    inflate_test_repo
  end

  context "when extracting a file that was moved" do
    let(:paths) { %w[new_name] }

    it "can follow the file's history" do
      ExtractRepo.run!(repo_path, paths)

      Dir.chdir output_dir do
        expect(File).to exist("new_name/new_name.txt")
      end
    end
  end

  it "has a version number" do
    expect(Foobara::ExtractRepo::VERSION).to_not be_nil
  end
end
