# m[y]org[anization]

This project is simple glue that combines
[fzf](https://github.com/junegunn/fzf),
[ripgrep](https://github.com/BurntSushi/ripgrep),
[rich](https://github.com/Textualize/rich), and [vim](https://www.vim.org/) to
help me manage notes.  It is opinionated and tailored for my usage. I love
[orgmode](https://orgmode.org/)  and [tiddlywiki](https://tiddlywiki.com/) but
they don't work for me.

I was looking for the following features:

* Quick capture
* Quick search across all note content
* Editing with vim
* Linking between notes (with automatic re-linking when a title changes)
* Syntax highlighting of code blocks

The Dockerfile, vimrc, and morg.sh files in this repository work together to
produce a note taking environment that works for me.

## Usage

All commands are executed in a container created from the
ghcr.io/mrxk/morg:main image. You must mount your local data directory as
`/morg` in the container. That is where all notes will be stored.  It can be
any path that can be mounted into a docker container. You can maintain
different collections of notes in different directories for different projects
or always use the same directory to keep all your notes together.

### Notes

Notes are similar to git commit messages in that the first line becomes the
title and filename of the note (with whitespace trimmed from the ends). Notes
are in `markdown` syntax with one addition. Text in double square brackets `[[`
and `]]` is expected to be the title of another note.

When editing a note, if the title is changed then all links to that note are
updated with the new title.  If the note was created by `gf` executed on a link
to a note that did note exist, then the note currently being edited is also
updated.

### Create a new note

```shell
docker run --rm -it -v $(pwd)/morg ghcr.io/mrxk/morg:main create
```

This command will open a vim editor for capturing your note. The following
mappings modifications are made to the default vim environment.

* Spaces are added as a valid filename character.
* The `<c-x><c-f>` insert mode file completion mapping has been overridden to
  invoke `fzf` on the notes directory.
* The `gl` normal mode mapping invokes `fzf` on the notes and inserts a link to
  the selected note.
* The `gf` normal mode mapping edits the note under the cursor. If the note
  does not exist it is crated.

### Browse notes


```shell
docker run --rm -it -v $(pwd)/morg ghcr.io/mrxk/morg:main
```

This command will invoke `fzf` on the notes directory. Queries are resolved
using `ripgrep` to search within notes. The preview window is populated by the
`view.py` script in this repository. The following key bindings are provided.

* ?       : toggle the preview window
* <ctrl-c>: create a new note
* <ctrl-d>: delete currently selected note
* <ctrl-h>: show keybindings
* <ctrl-n>: scroll preview window down
* <ctrl-p>: scroll preview window up
* <ctrl-w>: toggle preview wrap
* <enter> : edit selected note

