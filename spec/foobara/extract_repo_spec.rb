require "English"

RSpec.describe ExtractRepo do
  let(:repo_path) do
    "#{__dir__}/../fixtures/test_repo"
  end
  let(:output_dir) do
    # TODO: make this an input to ExtractRepo
    "/#{Dir.home}/tmp/extract/test_repo"
  end

  let(:repo_url) { repo_path }
  let(:delete_extracted) { false }
  let(:command) do
    described_class.new(repo_url:, paths:, delete_extracted:)
  end
  let(:outcome) { command.run }

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

  def rm_test_repo
    Dir.chdir(File.dirname(repo_path)) do
      # :nocov:
      if Dir.exist?("extract_repo")
        `rm -rf extract_repo`
        unless $CHILD_STATUS.exitstatus == 0
          raise "Failed to remove test repo"
        end
      end
      # :nocov:
    end
  end

  before do
    inflate_test_repo
    rm_test_repo
  end

  context "when extracting a file that was moved" do
    let(:paths) { %w[new_name] }

    it "can follow the file's history" do
      described_class.run!(repo_url: repo_path, paths:)

      Dir.chdir output_dir do
        expect(File).to exist("new_name/new_name.txt")
      end
    end

    context "when deleting extracted paths" do
      let(:delete_extracted) { true }

      it "deletes the extracted paths" do
        expect {
          expect(outcome).to be_success
        }.to change {
               Dir.entries(repo_path).include?("new_name")
             }
      end
    end
  end

  it "has a version number" do
    expect(Foobara::ExtractRepo::VERSION).to_not be_nil
  end

  context "when given a url" do
    let(:repo_url) { "http://example.com" }
    let(:paths) { [] }

    describe "#determine_absolute_repo_path" do
      it "just sets it to the repo_url" do
        command.cast_and_validate_inputs
        expect(command.determine_absolute_repo_path).to eq(repo_url)
      end
    end
  end
end
