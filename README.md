# extract-repo

Extracts files from one repository into a new repository, preserving complete git history of the extracted files.

## Usage

Pass the repo to extract code from and a list of directories/files to extract from that repo.

```
$ ./bin/extract-repo  some_file.rb some/directory/to/extract/
extract-repo --delete-extracted --repo-url-or-path git@github.com:org/repo.git --output-path new/repo/path --paths some/dir some/file.ext some/other/dir 
```

Results will wind up in `~/tmp/extract/` if you don't specify an `--output-path`

`--delete-extracted` will delete any files in the source repo that you extracted to the new repo.

## License

extract-repo is licensed under your choice of the Apache License 2.0 or the MIT license.
See [LICENSE.txt](LICENSE-MIT.txt) for more info about licensing.
