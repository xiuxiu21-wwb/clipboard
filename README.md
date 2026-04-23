# Clipboard History GUI for AutoHotkey v2

A lightweight clipboard history tool for Windows built with AutoHotkey v2.

It records recent clipboard items, shows them in a simple GUI, and lets you quickly copy or paste previous entries.

## Features

- Keeps up to 20 recent clipboard items
- Supports plain text clipboard history
- Detects image/file clipboard content and shows readable previews
- Restores copied image file paths as file drops
- Simple GUI list for selecting history items
- Paste selected item back into the previous active window
- Save and reload text/image-path history from disk
- Hotkey to clear clipboard history

## Requirements

- Windows
- [AutoHotkey v2](https://www.autohotkey.com/)

## File

- `clipboard_history_gui.ahk` — main script

## How to use

1. Install AutoHotkey v2.
2. Run `clipboard_history_gui.ahk`.
3. Copy text, image files, or file items as usual.
4. Press `Ctrl + Shift + V` or `F8` to open the clipboard history window.
5. Double-click an item or click `粘贴选中项` to paste it.
6. Click `仅复制不粘贴` to restore an item to the clipboard without pasting.
7. Press `Ctrl + Shift + C` to clear clipboard history.

## Hotkeys

- `Ctrl + Shift + V` — open clipboard history
- `F8` — open clipboard history
- `Ctrl + Shift + C` — clear clipboard history

## Notes

- Text and image-file-path history is saved to `clipboard_history_data.txt` in the script directory.
- Binary clipboard content is previewed in memory but is not persisted across restarts.
- If an image-path history entry points to a file that no longer exists, it will be skipped on reload.

## Recommended GitHub repository description

AutoHotkey v2 clipboard history GUI for Windows with quick paste, copy-only restore, and image/file preview support.
