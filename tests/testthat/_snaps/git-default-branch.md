# git_default_branch_rename() surfaces files that smell fishy

    Code
      git_default_branch_rename()
    Message
      i Local branch "master" appears to play the role of the default branch.
      v Moving local "master" branch to "main".
      [ ] Be sure to update files that refer to the default branch by name.
        Consider searching within your project for "master".
      x This GitHub Action file doesn't mention the new default branch "main":
        '.github/workflows/blah.yml'
      x Some badges appear to refer to the old default branch "master".
      [ ] Check and correct, if needed, in this file: 'README.md'
      x The bookdown configuration file may refer to the old default branch "master".
      [ ] Check and correct, if needed, in this file: 'whatever/foo/_bookdown.yaml'

