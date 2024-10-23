#Requires AutoHotkey v2.0

^+m::
{
    ; Clear the clipboard and ensure it's fully ready
    Clipboard := ""  ; Clear the clipboard to prepare for new data
    Sleep(100)       ; Give a small delay to ensure clipboard is cleared
    
    Send("^c")       ; Copy the selected text to clipboard
    Sleep(200)       ; Give a small delay to ensure clipboard has copied the text

    ; Access clipboard content using Windows API with proper Unicode handling
    clipboardContent := GetClipboardText()

    ; Check if clipboard content is empty
    if (clipboardContent = "") {
        return  ; Exit if the clipboard content is empty
    }

    ; Define the temp file paths in the same directory as the script
    tempMarkdownFile := A_ScriptDir "\temp_markdown.md"
    tempHtmlFile := A_ScriptDir "\temp_html.html"

    ; Check if the temp files exist and delete them if necessary
    if FileExist(tempMarkdownFile) {
        FileDelete(tempMarkdownFile)
    }
    
    if FileExist(tempHtmlFile) {
        FileDelete(tempHtmlFile)
    }

    ; Write the selected Markdown content to the temp markdown file
    FileAppend(clipboardContent, tempMarkdownFile, "UTF-8")

    ; Ensure the tempMarkdownFile was written correctly
    if !FileExist(tempMarkdownFile) {
        return  ; Exit if the markdown file wasn't created
    }

    ; Run Pandoc to convert the Markdown to HTML
    pandocPath := "pandoc"  ; You can use a full path like: C:\Path\to\pandoc.exe
    pandocCommand := 'cmd.exe /C "' pandocPath ' "' tempMarkdownFile '" -f markdown -t html -o "' tempHtmlFile '"'
    RunWait(pandocCommand, , 'Hide')

    ; Check if the HTML file was created
    if !FileExist(tempHtmlFile) {
        return  ; Exit if the HTML file wasn't created
    }

    ; Read the HTML result from the temp HTML file
    html := FileRead(tempHtmlFile, "UTF-8")

    ; Check if HTML content is read
    if (html = "") {
        return  ; Exit if HTML content is empty
    }

    ; Copy the HTML content into the clipboard using ClipboardSetText function
    SetClipboardText(html)

    ; Optional: Delete temp files after everything is done
    if FileExist(tempMarkdownFile) {
        FileDelete(tempMarkdownFile)
    }
    
    if FileExist(tempHtmlFile) {
        FileDelete(tempHtmlFile)
    }
}

; Function to access the clipboard text using Windows API with Unicode support
GetClipboardText() {
    DllCall("OpenClipboard", "UInt", 0)
    hClip := DllCall("GetClipboardData", "UInt", 13)  ; CF_UNICODETEXT (for Unicode text)
    pClip := DllCall("GlobalLock", "UInt", hClip)
    ClipText := StrGet(pClip, "UTF-16")
    DllCall("GlobalUnlock", "UInt", hClip)
    DllCall("CloseClipboard")
    return ClipText
}

; Function to set clipboard text explicitly for HTML content
SetClipboardText(text) {
    DllCall("OpenClipboard", "UInt", 0)
    DllCall("EmptyClipboard")
    hGlobal := DllCall("GlobalAlloc", "UInt", 0x0042, "UInt", (StrLen(text) + 1) * 2) ; 2 bytes per char (UTF-16)
    pGlobal := DllCall("GlobalLock", "Ptr", hGlobal)
    StrPut(text, pGlobal, "UTF-16")
    DllCall("GlobalUnlock", "Ptr", hGlobal)
    DllCall("SetClipboardData", "UInt", 13, "Ptr", hGlobal)  ; CF_UNICODETEXT
    DllCall("CloseClipboard")
}
