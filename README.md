# to-folder.yazi

> You go to create a folder. You type the name. You hit enter.
>
> But you forgot to add a `/` so it's actually a file. A string of curses ensues.
>
> Not anymore! Simply hit a key and the selected file(s) will be converted into folders with the same name.

This is a functional plugin for [Yazi](https://github.com/sxyazi/yazi) that converts the hovered file(s) into folders with the same name.

## Installation

```sh
ya pkg add drewlwhitney/to-folder
```

## Usage

`~/.config/yazi/init.lua`:

```lua
require("to-folder"):setup({
    --config
})
```

`~/.config/yazi/keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on = ["t", "f"]
run = "plugin to-folder"
desc = "Convert selected file(s) into folders"
```

## Config

Below are the default settings:

```lua
require("to-folder"):setup({
    prompt = true,
})
```

> [!NOTE]
> Settings use the default values unless overridden.

- `prompt`: Whether to prompt for confirmation when converting files to folders. The files are permanently deleted so this cannot be undone.
