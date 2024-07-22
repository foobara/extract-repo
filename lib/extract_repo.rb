require "pry"
require "English"
require "foobara/all"

class ExtractRepo < Foobara::Command
  inputs do
    repo_url :string, :required
    paths [:string], :required
    output_path :string, default: "/#{ENV.fetch("HOME", nil)}/tmp/extract"
  end

  attr_accessor :file_paths

  def execute
    mk_extract_dir
    rm_old_repo

    clone_repo
    remove_origin
    remove_tags
    determine_paths
    determine_historic_paths
    filter_repo
    remove_replaces
  end

  def chdir(dir, &)
    Dir.chdir(File.expand_path(dir), &)
  end

  def repo_dir
    File.join(output_path, repo_name)
  end

  def repo_name
    File.basename(repo_url, ".git")
  end

  def mk_extract_dir
    sh "mkdir -p #{output_path}"
  end

  def rm_old_repo
    sh "rm -rf #{repo_dir}"
  end

  def clone_repo
    chdir output_path do
      sh "git clone #{repo_url}"
    end
  end

  def remove_origin
    chdir repo_dir do
      sh "git remote rm origin"
    end
  end

  def remove_tags
    chdir repo_dir do
      sh "for i in `git tag`; do git tag -d $i; done"
    end
  end

  def remove_replaces
    chdir repo_dir do
      sh "git replace -l | xargs -n 1 git replace -d"
    end
  end

  def determine_paths
    chdir repo_dir do
      self.file_paths = []

      chdir repo_dir do
        paths.each do |path|
          unless File.exist?(path)
            # :nocov:
            raise "Path #{path} does not exist in repo #{repo_dir}"
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
    end

    normalize_file_paths
  end

  def determine_historic_paths
    chdir repo_dir do
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
    chdir repo_dir do
      path_args = file_paths.map { |path| "--path #{path}" }.join(" ")
      sh "git-filter-repo #{path_args} --force --prune-degenerate always"
    end
  end

  def sh(cmd, dry_run: false)
    puts cmd

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
