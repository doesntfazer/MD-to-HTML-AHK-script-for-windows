# Markdown to HTML Script for AHK

This is just a simple AHK script that converts MD to HTML so that you can quickly write documentation in MD.

## How it works

You highlight the text, press ***CTRL+SHIFT+M***, and it takes the contents of the clipboard, puts it in a temp md file, converts it to an html file using pandoc, then takes the contents of the html file and adds it to your clipboard so you can paste it wherever you need.

### Prerequsites
- Windows
- [AHK 2](https://www.autohotkey.com) installed
- [Pandoc](https://pandoc.org/installing.html) installed