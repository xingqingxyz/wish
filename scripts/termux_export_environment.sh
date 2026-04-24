WISH_ROOT=$(realpath -- "${BASH_SOURCE[0]}")
WISH_ROOT=${WISH_ROOT%/*/*}
EDITOR=edit
LANG=zh_CN.UTF-8
MANPAGER='sh -c "sed ''''s/\x1b\[[0-9;]*m\|.\x08//g'''' 2>/dev/null | bat -plman"'
MANROFFOPT='-c'
PAGER=less
RUSTUP_DIST_SERVER='https://mirrors.tuna.cn/rustup'
RUSTUP_UPDATE_ROOT='https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup'

MAPFILE=(
  --ignore-case
  --incsearch
  --quit-if-one-screen
  --search-options=W
  --use-color
  --wordwrap
  -R
)
LESS=${MAPFILE[*]}

MAPFILE=(
  --bind=alt-/:last
  --bind=alt-\\\\:first
  --bind=alt-b:preview-page-up
  --bind=alt-f:preview-page-down
  --bind=alt-J:jump
  --bind=alt-n:preview-down
  --bind=alt-p:preview-up
  --bind=alt-z:toggle-wrap
  --bind=btab:toggle-in
  --bind=ctrl-/:preview-bottom
  --bind=ctrl-\\\\:preview-top
  --bind=ctrl-a:toggle-all
  --bind=ctrl-alt-m:change-multi
  --bind=ctrl-b:page-up
  --bind=ctrl-backspace:backward-kill-subword
  --bind=ctrl-d:half-page-down
  --bind=ctrl-delete:kill-word
  --bind=ctrl-f:page-down
  --bind=ctrl-left:backward-word
  --bind=ctrl-right:forward-word
  --bind=ctrl-u:half-page-up
  --bind=tab:toggle-out
)
FZF_DEFAULT_OPTS=${MAPFILE[*]}

MAPFILE=(
  127.0.0.1
  localhost
  internal.domain
  kkgithub.com
  mirror.sjtu.edu.cn
  mirrors.tuna.tsinghua.edu.cn
  mirrors.ustc.edu.cn
  raw.githubusercontents.com
)
IFS=, no_proxy=${MAPFILE[*]}

MAPFILE=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  "$HOME/.bun/bin"
  "$PREFIX/local/bin"
  "$PREFIX/bin"
)
IFS=: PATH=${MAPFILE[*]}

if JAVA_HOME=$(type -P java 2> /dev/null); then
  JAVA_HOME=$(realpath "$JAVA_HOME")
  JAVA_HOME=${JAVA_HOME%/*/*}
fi

MAPFILE=(
  "EDITOR=$EDITOR"
  "FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS"
  "JAVA_HOME=$JAVA_HOME"
  "LANG=$LANG"
  "LESS=$LESS"
  "MANPAGER=$MANPAGER"
  "MANROFFOPT=$MANROFFOPT"
  "no_proxy=$no_proxy"
  "PAGER=$PAGER"
  "PATH=$PATH"
  "RUSTUP_DIST_SERVER=$RUSTUP_DIST_SERVER"
  "RUSTUP_UPDATE_ROOT=$RUSTUP_UPDATE_ROOT"
  "WISH_ROOT=$WISH_ROOT"
)
export "${MAPFILE[@]}"
printf '%s\n' "${MAPFILE[@]}" > ~/.env

# clean
IFS=$' \n\t'
