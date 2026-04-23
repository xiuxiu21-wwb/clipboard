#Requires AutoHotkey v2.0
#SingleInstance Force

global maxItems := 20
global clipboardHistory := []
global lastTextClip := ""
global historyGui := ""
global historyList := ""
global historySnapshot := []
global lastTargetHwnd := 0
global suppressClipboardHook := false
global nextClipboardId := 1
global historyFile := A_ScriptDir "\clipboard_history_data.txt"

LoadHistory()
OnClipboardChange ClipChanged

ClipChanged(dataType) {
    global lastTextClip, suppressClipboardHook

    if suppressClipboardHook
        return

    clipData := ClipboardAll()

    if HasImageFormat() || HasFileDropFormat() {
        preview := GetRichClipboardPreview()
        AddHistoryItem({ kind: "binary", data: clipData, preview: preview }, false)
        return
    }

    if (dataType != 1)
        return

    clip := Trim(A_Clipboard, "`r`n`t ")
    if (clip = "")
        return

    if IsImageFilePath(clip) {
        AddHistoryItem({ kind: "image_path", data: clip, preview: "[图片文件] " FileNameOnly(clip) "（图片）" }, true)
        return
    }

    if (clip = lastTextClip)
        return

    lastTextClip := clip
    AddHistoryItem({ kind: "text", data: clip, preview: PreviewText(clip) "（文字）" }, true)
}

AddHistoryItem(entry, persist := false) {
    global clipboardHistory, maxItems, nextClipboardId

    for index, item in clipboardHistory {
        if (item.kind = entry.kind && item.preview = entry.preview) {
            if ((entry.kind = "text" || entry.kind = "image_path") && item.data = entry.data) {
                clipboardHistory.RemoveAt(index)
                break
            }
        }
    }

    entry.id := nextClipboardId
    nextClipboardId += 1
    clipboardHistory.InsertAt(1, entry)

    while (clipboardHistory.Length > maxItems)
        clipboardHistory.Pop()

    if persist
        SaveHistory()

    RefreshHistoryList()
}

RefreshHistoryList() {
    global clipboardHistory, historyGui, historyList, historySnapshot

    if !IsObject(historyGui) || !IsObject(historyList)
        return

    try selectedIndex := historyList.Value
    catch
        return

    if (selectedIndex < 1)
        selectedIndex := 1

    historySnapshot := []

    try historyList.Delete()
    catch
        return

    for _, item in clipboardHistory {
        historySnapshot.Push(item)
        try historyList.Add(["#" item.id " · " item.preview])
        catch
            return
    }

    if (historySnapshot.Length > 0) {
        if (selectedIndex > historySnapshot.Length)
            selectedIndex := historySnapshot.Length
        try historyList.Choose(selectedIndex)
    }
}

LoadHistory() {
    global clipboardHistory, nextClipboardId, historyFile, maxItems

    clipboardHistory := []
    nextClipboardId := 1

    if !FileExist(historyFile)
        return

    content := FileRead(historyFile, "UTF-8")
    if (content = "")
        return

    lines := StrSplit(content, "`n", "`r")
    maxSeenId := 0

    for _, line in lines {
        line := Trim(line, "`r`t ")
        if (line = "")
            continue

        parts := StrSplit(line, "`t")
        if (parts.Length < 4)
            continue

        id := Integer(parts[1])
        kind := parts[2]
        data := UnescapeField(parts[3])
        preview := UnescapeField(parts[4])

        if (kind != "text" && kind != "image_path")
            continue

        if (kind = "image_path" && !FileExist(data))
            continue

        clipboardHistory.Push({ id: id, kind: kind, data: data, preview: preview })
        if (id > maxSeenId)
            maxSeenId := id
    }

    if (clipboardHistory.Length > maxItems) {
        while (clipboardHistory.Length > maxItems)
            clipboardHistory.Pop()
    }

    nextClipboardId := maxSeenId + 1
}

SaveHistory() {
    global clipboardHistory, historyFile

    lines := []
    for _, item in clipboardHistory {
        if (item.kind = "text" || item.kind = "image_path")
            lines.Push(item.id "`t" item.kind "`t" EscapeField(item.data) "`t" EscapeField(item.preview))
    }

    text := ""
    for _, line in lines
        text .= line "`n"

    FileDelete(historyFile)
    FileAppend(text, historyFile, "UTF-8")
}

EscapeField(text) {
    text := StrReplace(text, Chr(96), "``")
    text := StrReplace(text, "`t", "``t")
    text := StrReplace(text, "`n", "``n")
    text := StrReplace(text, "`r", "``r")
    return text
}

UnescapeField(text) {
    result := ""
    i := 1
    while (i <= StrLen(text)) {
        ch := SubStr(text, i, 1)
        if (ch = Chr(96) && i < StrLen(text)) {
            nxt := SubStr(text, i + 1, 1)
            if (nxt = "t") {
                result .= "`t"
                i += 2
                continue
            }
            if (nxt = "n") {
                result .= "`n"
                i += 2
                continue
            }
            if (nxt = "r") {
                result .= "`r"
                i += 2
                continue
            }
            if (nxt = Chr(96)) {
                result .= Chr(96)
                i += 2
                continue
            }
        }
        result .= ch
        i += 1
    }
    return result
}

HasImageFormat() {
    return DllCall("IsClipboardFormatAvailable", "UInt", 2)
        || DllCall("IsClipboardFormatAvailable", "UInt", 8)
        || DllCall("IsClipboardFormatAvailable", "UInt", 17)
}

HasFileDropFormat() {
    return DllCall("IsClipboardFormatAvailable", "UInt", 15)
}

GetRichClipboardPreview() {
    text := Trim(A_Clipboard, "`r`n`t ")

    if HasFileDropFormat() {
        first := FirstLine(text)
        if IsImageFilePath(first)
            return "[图片文件] " FileNameOnly(first) "（图片）"
        if (first != "")
            return "[文件] " FileNameOnly(first)
        return "[文件] 已复制文件"
    }

    if HasImageFormat()
        return "[图片] 剪贴板图像（图片）"

    return "[富媒体] 非文本剪贴板内容"
}

IsImageFilePath(text) {
    if (text = "")
        return false
    if InStr(text, "`n") || InStr(text, "`r")
        return false
    if !FileExist(text)
        return false

    SplitPath text, , , &ext
    ext := StrLower(ext)
    return ext = "png"
        || ext = "jpg"
        || ext = "jpeg"
        || ext = "bmp"
        || ext = "gif"
        || ext = "webp"
        || ext = "ico"
        || ext = "tif"
        || ext = "tiff"
}

FileNameOnly(path) {
    SplitPath path, &name
    return name
}

FirstLine(text) {
    if (text = "")
        return ""
    parts := StrSplit(text, "`n")
    return Trim(parts[1], "`r`t ")
}

SetClipboardFiles(paths) {
    static CF_HDROP := 0xF
    static GHND := 0x42

    if !IsObject(paths)
        paths := [paths]

    fileList := ""
    for _, path in paths
        fileList .= path . Chr(0)
    fileList .= Chr(0)

    bytes := StrPut(fileList, "UTF-16") * 2
    hGlobal := DllCall("GlobalAlloc", "UInt", GHND, "UPtr", 20 + bytes, "Ptr")
    pGlobal := DllCall("GlobalLock", "Ptr", hGlobal, "Ptr")

    NumPut("UInt", 20, pGlobal, 0)
    NumPut("Int", 0, pGlobal, 4)
    NumPut("Int", 0, pGlobal, 8)
    NumPut("Int", 0, pGlobal, 12)
    NumPut("Int", 1, pGlobal, 16)
    StrPut(fileList, pGlobal + 20, "UTF-16")

    DllCall("GlobalUnlock", "Ptr", hGlobal)
    DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)
    DllCall("EmptyClipboard")
    DllCall("SetClipboardData", "UInt", CF_HDROP, "Ptr", hGlobal)
    DllCall("CloseClipboard")
}

^+v::ShowClipboardHistory()
F8::ShowClipboardHistory()

^+c:: {
    global clipboardHistory, historyGui
    clipboardHistory := []
    SaveHistory()
    try historyGui.Destroy()
}

ShowClipboardHistory() {
    global clipboardHistory, historyGui, historyList, historySnapshot, lastTargetHwnd

    lastTargetHwnd := WinExist("A")

    if (clipboardHistory.Length = 0) {
        MsgBox "剪贴板历史为空。"
        return
    }

    if IsObject(historyGui) {
        try historyGui.Destroy()
    }

    historySnapshot := []
    for _, item in clipboardHistory
        historySnapshot.Push(item)

    historyGui := Gui("+AlwaysOnTop", "剪贴板历史")
    historyGui.SetFont("s10", "Microsoft YaHei")

    historyList := historyGui.Add("ListBox", "w700 r12")
    for _, item in historySnapshot
        historyList.Add(["#" item.id " · " item.preview])

    historyList.OnEvent("DoubleClick", SelectClipboardItem)
    historyGui.OnEvent("Escape", DestroyHistoryGui)
    historyGui.OnEvent("Close", DestroyHistoryGui)

    btnUse := historyGui.Add("Button", "xm w100", "粘贴选中项")
    btnUse.OnEvent("Click", SelectClipboardItem)

    btnCopy := historyGui.Add("Button", "x+10 w120", "仅复制不粘贴")
    btnCopy.OnEvent("Click", CopyOnlyClipboardItem)

    btnClear := historyGui.Add("Button", "x+10 w100", "清空历史")
    btnClear.OnEvent("Click", ClearClipboardHistory)

    historyList.Choose(1)
    historyGui.Show()
}

SelectClipboardItem(*) {
    global historySnapshot, historyList, historyGui, lastTargetHwnd

    index := historyList.Value
    if (index < 1 || index > historySnapshot.Length)
        return

    entry := historySnapshot[index]
    ApplyClipboardEntry(entry)

    if lastTargetHwnd {
        try WinActivate("ahk_id " lastTargetHwnd)
        Sleep 40
    }

    Send "^v"

    try historyGui.Show("NoActivate")
}

CopyOnlyClipboardItem(*) {
    global historySnapshot, historyList, historyGui

    index := historyList.Value
    if (index < 1 || index > historySnapshot.Length)
        return

    entry := historySnapshot[index]
    ApplyClipboardEntry(entry)

    try historyGui.Destroy()
}

ApplyClipboardEntry(entry) {
    global suppressClipboardHook

    suppressClipboardHook := true
    try {
        if (entry.kind = "image_path") {
            SetClipboardFiles([entry.data])
            return
        }

        A_Clipboard := entry.data
        ClipWait(0.2)
    } finally {
        SetTimer () => suppressClipboardHook := false, -150
    }
}

ClearClipboardHistory(*) {
    global clipboardHistory, historyGui
    clipboardHistory := []
    SaveHistory()
    RefreshHistoryList()
    DestroyHistoryGui()
}

DestroyHistoryGui(*) {
    global historyGui, historyList
    try historyGui.Destroy()
    historyGui := ""
    historyList := ""
}

PreviewText(text) {
    text := StrReplace(text, "`r", " ")
    text := StrReplace(text, "`n", " ")
    text := RegExReplace(text, "\s+", " ")
    if (StrLen(text) > 80)
        text := SubStr(text, 1, 80) "..."
    return text
}
