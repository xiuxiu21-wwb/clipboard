# Clipboard History GUI / 剪贴板历史工具

A lightweight clipboard history GUI for Windows built with AutoHotkey v2.

一个基于 AutoHotkey v2 的 Windows 剪贴板历史工具，提供简洁的图形界面，方便快速查看、复制和粘贴最近的剪贴板内容。

## Features / 功能特点

- Keep up to 20 recent clipboard entries  
  最多保存 20 条最近剪贴板记录
- Supports plain text history  
  支持纯文本剪贴板历史
- Detects image/file clipboard content and shows readable previews  
  自动识别图片/文件类剪贴板内容，并显示易读预览
- Restores copied image file paths as file drops  
  图片文件路径可恢复为文件拖放类型剪贴板
- Simple GUI list for browsing and selecting history items  
  提供简洁 GUI 列表用于浏览和选择历史项
- Paste selected content back into the previously active window  
  可将选中内容直接粘贴回上一个活动窗口
- Save and reload text/image-path history from disk  
  文本和图片路径历史支持本地保存与重载
- Hotkey to clear all saved clipboard history  
  提供快捷键一键清空历史

## Requirements / 运行环境

- Windows
- [AutoHotkey v2](https://www.autohotkey.com/)

## File / 文件说明

- `clipboard_history_gui.ahk` — main script / 主脚本

## How to Use / 使用方法

1. Install AutoHotkey v2.  
   安装 AutoHotkey v2。
2. Run `clipboard_history_gui.ahk`.  
   运行 `clipboard_history_gui.ahk`。
3. Copy text, image files, or file items as usual.  
   像平时一样复制文字、图片文件或文件项。
4. Press `Ctrl + Shift + V` or `F8` to open the clipboard history window.  
   按 `Ctrl + Shift + V` 或 `F8` 打开剪贴板历史窗口。
5. Double-click an item, or click `粘贴选中项` to paste it.  
   双击某一项，或点击 `粘贴选中项` 将其粘贴出去。
6. Click `仅复制不粘贴` if you only want to restore it to the clipboard.  
   如果只想恢复到剪贴板而不立即粘贴，可点击 `仅复制不粘贴`。
7. Press `Ctrl + Shift + C` to clear clipboard history.  
   按 `Ctrl + Shift + C` 清空剪贴板历史。

## Hotkeys / 快捷键

- `Ctrl + Shift + V` — open clipboard history / 打开剪贴板历史
- `F8` — open clipboard history / 打开剪贴板历史
- `Ctrl + Shift + C` — clear clipboard history / 清空剪贴板历史

## Data Storage / 数据存储

- Text and image-path history is saved to `clipboard_history_data.txt` in the script directory.  
  文本和图片路径历史会保存到脚本目录下的 `clipboard_history_data.txt`。
- Binary clipboard content is previewed in memory but is not persisted across restarts.  
  二进制剪贴板内容只会在内存中预览，不会跨重启持久保存。
- If an image-path entry points to a file that no longer exists, it will be skipped when reloading.  
  如果某条图片路径记录对应的文件已不存在，重新加载时会自动跳过。

## Suitable Scenarios / 适用场景

- Frequently copying and reusing text snippets  
  高频复制和复用文本片段
- Quickly switching between multiple copied items  
  需要在多个复制项之间快速切换
- Temporarily keeping copied image/file references  
  临时保留图片/文件复制记录
- Improving daily Windows copy-paste workflow  
  提升日常 Windows 复制粘贴效率

## Suggested GitHub Description / 推荐仓库描述

AutoHotkey v2 clipboard history GUI for Windows with quick paste, copy-only restore, and image/file preview support.
