# creates correct default package files

    Code
      use_air()
    Message
      v Creating 'air.toml'.
      v Adding "^[.]?air[.]toml$" to '.Rbuildignore'.
      v Creating '.vscode/'.
      v Adding "^\\.vscode$" to '.Rbuildignore'.
      v Creating '.vscode/settings.json'.
      v Creating '.vscode/extensions.json'.
      [ ] Read Air's editors guide (<https://posit-dev.github.io/air/editors.html>)
        to learn how to invoke Air in your preferred editor.
      [ ] Read Air's GitHub Actions guide
        (<https://posit-dev.github.io/air/integration-github-actions.html>) to learn
        about GHA workflows that continuously run formatting checks.

---

    Code
      writeLines(read_utf8(proj_path(".vscode", "settings.json")))
    Output
      {
          "[r]": {
              "editor.formatOnSave": true,
              "editor.defaultFormatter": "Posit.air-vscode"
          },
          "[quarto]": {
              "editor.formatOnSave": true,
              "editor.defaultFormatter": "quarto.quarto"
          }
      }

---

    Code
      writeLines(read_utf8(proj_path(".vscode", "extensions.json")))
    Output
      {
          "recommendations": [
              "Posit.air-vscode"
          ]
      }

