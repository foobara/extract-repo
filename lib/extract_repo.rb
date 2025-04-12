require "pry"
require "uri"
require "English"

require "foobara/all"

# TODO: allow extracting from a local repo and default to that repo as "."
class ExtractRepo < Foobara::Command
  description "Extracts directories/files of your choosing from one repo to another"

  inputs do
    repo_url_or_path :string, :required, "The source repository to extract from. Can be a URL or a local directory"
    paths [:string], :required, "Paths to each directory/file to extract"
    output_path :string, default: "#{Dir.home}/tmp/extract",
                         description: "Where to create a new repo and move the extracted files to"
    delete_extracted :boolean, default: false, description: "Delete the extracted files from the source repository"
  end

  attr_accessor :file_paths, :absolute_repo_path

  def execute
    determine_absolute_repo_path
    mk_extract_dir
    rm_old_repo

    clone_repo
    remove_origin
    remove_tags
    determine_paths
    determine_historic_paths
    filter_repo
    remove_replaces

    delete_extracted_paths if delete_extracted?
  end

  def determine_absolute_repo_path
    self.absolute_repo_path = if local_repository?
                                File.absolute_path(repo_url_or_path)
                              else
                                repo_url_or_path
                              end
  end

  def chdir(dir, &)
    Dir.chdir(File.expand_path(dir), &)
  end

  def mk_extract_dir
    sh "mkdir -p #{output_path}"
  end

  def rm_old_repo
    sh "rm -rf #{output_path}"
  end

  def clone_repo
    sh "git clone #{absolute_repo_path} #{output_path}"
  end

  def local_repository?
    !URI.parse(repo_url_or_path).scheme
  end

  def remove_origin
    chdir output_path do
      sh "git remote rm origin"
    end
  end

  def remove_tags
    chdir output_path do
      sh "for i in `git tag`; do git tag -d $i; done"
    end
  end

  def remove_replaces
    chdir output_path do
      replace_sha1s = sh "git replace -l", silent: true
      replace_sha1s = replace_sha1s.chomp.split("\n")
      replace_sha1s.each do |replace_sha1|
        # It seems like some versions of git do not create replace markers when doing this
        # :nocov:
        sh "git replace -d #{replace_sha1}"
        # :nocov:
      end
    end
  end

  def determine_paths
    chdir output_path do
      self.file_paths = []

      paths.each do |path|
        unless File.exist?(path)
          # :nocov:
          raise "Path #{path} does not exist in repo #{output_path}"
          # :nocov:
        end

        if File.directory?(path)
          Dir.glob("#{path}/**/*").each do |file|
            file_paths << file if File.file?(file)
          end
        else
          # TODO: test this path
          # :nocov:
          file_paths << path
          # :nocov:
        end
      end
    end

    normalize_file_paths
  end

  def determine_historic_paths
    chdir output_path do
      file_paths.dup.each do |file_path|
        historic_paths = sh "git log --follow --name-only --pretty=format: -- \"#{file_path}\""

        historic_paths.split("\n").each do |historic_path|
          file_paths << historic_path
        end
      end
    end

    normalize_file_paths
  end

  def normalize_file_paths
    file_paths.sort!
    file_paths.uniq!
    file_paths.reject!(&:empty?)
  end

  def filter_repo
    chdir output_path do
      path_args = file_paths.map { |path| "--path #{path}" }.join(" ")
      sh "git-filter-repo #{path_args} --force --prune-degenerate always"
    end
  end

  # This feels dangerous however it is opt-in at least
  def delete_extracted_paths
    return unless local_repository?

    Dir.chdir absolute_repo_path do
      paths.each do |path|
        FileUtils.rm_r path
      end
    end
  end

  def delete_extracted?
    delete_extracted
  end

  def sh(cmd, dry_run: false, silent: false)
    unless silent
      puts cmd
    end

    return if dry_run

    result = `#{cmd}`

    unless $CHILD_STATUS.success?
      # :nocov:
      raise "Command #{cmd} failed with status #{$CHILD_STATUS.exitstatus}: #{result}"
      # :nocov:
    end

    result
  end
end
