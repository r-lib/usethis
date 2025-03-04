# creates correct default package files

    Code
      writeLines(read_utf8(proj_path(".vscode", "settings.json")))
    Output
      {
          "[r]": {
              "editor.formatOnSave": true,
              "editor.defaultFormatter": "Posit.air-vscode"
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

