#!/bin/bash

set -euf -o pipefail

if [ -n "${DEBUG:-}" ]
then
    set -x
fi

MORG_ROOT="${MORG_ROOT:-/morg}"

usage () {
    >&2 echo "Usage ${0} [command]"
    >&2 echo "  Commands:"
    >&2 echo "    create         - create a new note"
    >&2 echo "    edit [title]   - edit a note"
    >&2 echo "    delete [title] - deete a note"
    >&2 echo "    keybindings    - show key bindings"
    >&2 echo "    show           - show all notes"
}

die() {
  local message=${1}
  >&2 echo "${message}"
  exit 1
}

create () {
    # optional filename
    local filename="${1:-}"
    local work_file=$(mktemp)
    trap "rm -f ${work_file}" RETURN
    trap "rm -f ${work_file}" SIGINT
    trap "rm -f ${work_file}" SIGKILL
    filename=$(echo "${filename}" | xargs) # strip whitespace
    if [ -n "${filename}" ]
    then
        echo "${filename}" > "${work_file}"
    fi
    vim "+set filetype=markdown" "${work_file}"
    local title=$(head -1 "${work_file}"|xargs) # strip whitespace
    if [ -z "${title}" ]
    then
        >&2 echo "Aborting due to empty title line."
        return 1
    fi
    mv "${work_file}" "${MORG_ROOT}/${title}"
    chmod a-w "${MORG_ROOT}/${title}"
    # if the name was changed after creation then relink
    if [ -n "${filename}" ] && [ "${filename}" != "${title}" ]
    then
        relink "${filename}" "${title}"
    fi
}

delete () {
    local filename=${1}
    read -p "Delete ${1} [y/N]? " answer
    if [ "${answer}" == "y" ]
    then
        rm -f "${MORG_ROOT}/${filename}"
    fi
}

edit () {
    local filename=${1}
    local orig_title=$(head -1 "${filename}"|xargs) # strip whitespace
    work_file=$(mktemp)
    trap "rm -f ${work_file}" RETURN
    trap "rm -f ${work_file}" SIGINT
    trap "rm -f ${work_file}" SIGKILL
    cp "${MORG_ROOT}/${filename}" "${work_file}"
    vim "+set filetype=markdown" "${work_file}"
    title=$(head -1 "${work_file}"|xargs) # strip whitespace
    if [ -z "${title}" ]
    then
        >&2 echo "Aborting due to empty title line."
        return 0
    fi

    # if unchanged, do not update original
    diff "${work_file}" "${MORG_ROOT}/${title}" && return 0

    # preserve creaion timestamp
    chmod +w "${MORG_ROOT}/${title}"
    cat "${work_file}" > "${MORG_ROOT}/${title}"
    chmod a-w "${MORG_ROOT}/${title}"
    if [ "${title}" != "${orig_title}" ]
    then
        rm -f "${MORG_ROOT}/${filename}"
        relink "${orig_title}" "${title}"
        echo "${title}" # so currently editing files can update
    fi
}

relink () {
    local orig_title=${1}
    local new_title=${2}
    find "${MORG_ROOT}" -type f | while read file
    do
      local mtime=$(date -R -r "${file}")
      sed  -i "s/\[\[\s*${orig_title}\s*\]\]/\[\[${new_title}\]\]/g" "${file}"
      touch -m -d "${mtime}" "${file}"
    done
    echo "${new_title}" > /tmp/RELINK
}

keybindings () {
    echo "?: toggle preview window"
    echo "ctrl-c: create a new note"
    echo "ctrl-d: delete currently selected note"
    echo "ctrl-h: show keybindings"
    echo "ctrl-n: scroll preview window down"
    echo "ctrl-p: scroll preview window up"
    echo "ctrl-w: toggle preview wrap"
    echo "enter: edit selected note"
    read -p "Enter to continue" trash
}

show () {
    while :
    do
    RG_PREFIX="rg -l --no-heading  --smart-case --sortr created"
    FZF_DEFAULT_COMMAND="${RG_PREFIX} ''" \
      fzf --bind "change:reload(${RG_PREFIX} {q} || true)" \
          --bind "?:toggle-preview" \
          --bind "ctrl-c:execute(${0} create)+reload(${RG_PREFIX} {q} || true)" \
          --bind "ctrl-d:execute(${0} delete {})+reload(${RG_PREFIX} {q} || true)" \
          --bind "ctrl-h:execute(${0} keybindings)" \
          --bind "ctrl-n:preview-down" \
          --bind "ctrl-p:preview-up" \
          --bind "ctrl-w:toggle-preview-wrap" \
          --bind "enter:execute(${0} edit {})+reload(${RG_PREFIX} {q} || true)" \
          --prompt "search (ctrl-h for help)> " \
          --phony \
          --preview "/app/view.py {}" \
          --preview-window 'right:60%' \
          --layout reverse \
          --border \
          --info hidden
    done
}

cd "${MORG_ROOT}" || die "ERROR: ${MORG_ROOT} must be mounted to your data directory."

case "${1:-}" in
    "create")
        create "${2:-}"
        ;;
    "edit")
        edit "${2}"
        ;;
    "delete")
        delete "${2}"
        ;;
    "keybindings")
        keybindings
        ;;
    "show")
        show
        ;;
    *)
        show
        ;;
esac

