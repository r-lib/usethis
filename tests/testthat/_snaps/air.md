# creates correct default package files

    Code
      cat(read_utf8(proj_path(".vscode", "settings.json")), sep = "\n")
    Output
      {
          "[r]": {
              "editor.formatOnSave": true,
              "editor.defaultFormatter": "Posit.air-vscode"
          }
      }

---

    Code
      cat(read_utf8(proj_path(".vscode", "extensions.json")), sep = "\n")
    Output
      {
          "recommendations": [
              "Posit.air-vscode"
          ]
      }

