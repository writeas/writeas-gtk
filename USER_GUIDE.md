# User Guide

Write.as GTK is a lightweight, distraction-free editor for getting your thoughts down as soon as they come to you.

It launches in an instant to a blank page, ready for your words. As you type, your writing is automatically saved, and will be there waiting for you every time you open the app. If you want to share your writing, you can anonymously publish it to Write.as, where you'll get a simple URL you can share on social media, in an email, or anywhere else.

[Write.as](https://write.as) is a simple, privacy-focused blogging platform that lets you publish without ever signing up. There's no ads, no tracking you around the web, and no profiting from your personal data. It's a space where you can write freely, for free, without worrying about who's watching.

## Writing

Write.as GTK automatically saves your writing as you type, so you don't have to worry about losing your data (see [File locations](#file-locations) for where the draft is stored).

## Customizing the editor

**Font**. Change this by selecting from the _Document font_ menu in the top-left corner of the window. You can choose between three fonts: Serif (Lora), Sans-serif (Open Sans), or Monospace (Hack). The selected font will determine how text looks while you write, as well as what the post looks like when published on Write.as.

**Text size**. Change this by pressing Ctrl and + or - to increase or decrease the text size, respectively. This only affects the appearance of the editor, and not posts published on Write.as.

**Dark mode**. When a desktop theme defines a dark mode, you can change into it by clicking the _Dark mode_ button in the top-right corner of the editor, next to the _Publish_ button -- or by pressing Ctrl + T. This only affects the appearance of the editor, and not posts published on Write.as.

## Keyboard shortcuts

| Shortcut | Command |
| -------- | ------- |
| Ctrl + T | Toggle light / dark theme (where supported) |
| Ctrl + - | Decrease text size |
| Ctrl + + | Increase text size |
| Ctrl + S | Save file as... |
| Ctrl + Enter | Publish file to Write.as |

**Standard shortcuts**

| Shortcut | Command |
| -------- | ------- |
| Ctrl + A | Select all |
| Ctrl + C | Copy |
| Ctrl + X | Cut |
| Ctrl + V | Paste |
| Ctrl + Z | Undo |
| Ctrl + Shift + Z | Redo |
| Ctrl + W / Q | Quit |
| F11 | Full-screen |

## Publishing to Write.as

Write.as GTK lets you share what you've written with anyone by publishing to [Write.as](https://write.as).
Once you've finished writing, press the _Publish_ button in the top-right corner of the editor (or press Ctrl + Enter) to publish your post.
Your browser will open to the post on Write.as, and its URL will be copied to your clipboard so you can paste it wherever you want to share it.
Behind the scenes, the CLI will store the special information needed to edit or delete the post in the future (see [Managing posts](#managing-posts) below for how to do this).

After the post is published, you can press Ctrl + S to permanently save the file on your computer, or delete everything in the file to start fresh.

## Managing posts

Published posts are managed by [writeas-cli](https://github.com/writeas/writeas-cli). See its [User Guide](https://github.com/writeas/writeas-cli/blob/master/GUIDE.md) for how to update and delete posts on Write.as via the command-line.

## File locations

Files from the GTK app are stored in the same folder that the CLI uses: `~/.writeas`

Your auto-saved draft is located at: `~/.writeas/draft.txt`

Preferences for the appearance of the editor and publishing settings are stored here: `~/.writeas/prefs.ini`
