# git_default_branch_rename() surfaces files that smell fishy

    Code
      git_default_branch_rename()
    Message <message>
      i Local branch 'master' appears to play the role of the default branch.
      v Moving local 'master' branch to 'main'.
      * Be sure to update files that refer to the default branch by name.
        Consider searching within your project for 'master'.
      x These GitHub Action files don't mention the new default branch 'main':
        - '.github/workflows/blah.yml'
      x Some badges may refer to the old default branch 'master':
        - 'README.md'
      x The bookdown configuration file may refer to the old default branch 'master':
        - 'whatever/foo/_bookdown.yaml'

