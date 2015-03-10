#!/bin/bash
# a quick and dirty meta pkg installer
#
#TODO: output help if used wrong
#
###############################################################################
set -e

[ "$GIMME_URL" ]  ||  GIMME_URL="http://git.kylepdavis.com/kylepdavis/gimme.git"
[ "$GIMME_DIR" ]  ||  GIMME_DIR="$HOME/.gimme"

alias getme=gimme
alias giveme=gimme

has() {
	which "$1" >/dev/null
}

pkgtool() {
	if [[ "$OS" = "Darwin" ]]; then
		brew "$@"
	else
		sudo apt-get -y "$@"
	fi
}

_gimmepkg() {
	pkgtool install "$@"
}

_GIMMES=

__gimme() {
	local PKG="$1"
	! [[ "$_GIMMES" == *" $PKG "* ]]  ||  return 0
	_GIMMES+=" $PKG "
	case "$PKG" in
	dotfiles)
		#TODO: get and install these
		#TODO: difficulty: should be able to setup dotfiles + bash + base tools all in one command ;-)
		#TODO: protip:   curl -sLo- $URL  |  bash    # ftw
		echo ... //TODO: $PKG ...
	;;
	gcc)
		if [[ "$OS" = "Darwin" ]]; then
			"xcode-select" --install 2>&1 | grep -q "already installed"
		else
			_gimmepkg build-essential
			_gimme curl
		fi
	;;
	bash_profile) _gimme liquidprompt
		[[ -f "$HOME/.bash_profile" ]]  ||  ln -sv "$HOME/.profile" "$HOME/.bash_profile"
		[[ -f "$HOME/.bashrc" ]]        ||  ln -sv "$HOME/.profile" "$HOME/.bashrc"
	;;
	liquidprompt) _gimme bash_profile git
		[[ -d "$HOME/liquidprompt" ]]  ||  git clone "https://github.com/nojhan/liquidprompt.git" "$HOME/liquidprompt"
	;;
	git)
		has git  ||  _gimmepkg git
		if ! [[ -f "$HOME/.gitconfig" ]]; then
			git config --global color.ui true
			if [[ "$OS" = "Darwin" ]]; then
				git config --global credential.helper "osxkeychain"
			else
				git config --global credential.helper "cache --timeout=3600"
			fi
		fi
	;;
	git-extras) _gimme git
		has git-alias  ||  (cd /tmp && git clone --depth 1 https://github.com/tj/git-extras.git && cd git-extras && sudo make install)
		if ! [[ "$(git alias)" ]]; then
			git alias br branch
			git alias ci commit
			git alias co checkout
			git alias di diff
			git alias st status
		fi
	;;
	python)
		if [[ "$OS" = "Darwin" ]]; then
			mkdir -p "$PYTHONPATH"
		fi
		has python  ||  _gimmepkg python
	;;
	pylint|pep8) _gimme python
		if ! has "$PKG"; then
			if [[ "$OS" = "Darwin" ]]; then
				easy_install -d "$PYTHONPATH" "$PKG"
				ln -sv "$PYTHONPATH/$PKG" "$(brew --prefix)/bin/$PKG"
			else
				easy_install "$PKG"
			fi
		fi
	;;
	node)
		if [[ "$OS" = "Darwin" ]]; then
			has node  ||  _gimmepkg node
		else #TODO: might get old version here ...
			_gimme nodejs npm
		fi
	;;
	jshint|js-beautify|json)
		if [[ "$OS" = "Darwin" ]]; then
			has "$PKG"  ||  npm install -g "$PKG"
		else
			has "$PKG"  ||  sudo npm install -g "$PKG"
		fi
	;;
	mongodb)
		has "mongod"  ||  _gimmepkg mongodb
	;;
	redis)
		if ! has "redis-server"; then
			if [[ "$OS" = "Darwin" ]]; then
				_gimmepkg redis
			else
				_gimmepkg redis-server
			fi
		fi
	;;
	go)
		_gimme curl
		#TODO: setup go vs golang dirs?
		if ! which "$PKG" >/dev/null; then
			if [[ "$OS" = "Darwin" ]]; then
				_gimmepkg go --cross-compile-common
			else
				_gimmepkg golang
			fi
		fi
	;;
	difftool)
		_gimme colordiff
	;;
	mergetool)
		if [[ "$OS" = "Darwin" ]]; then
			true #TODO: usually use opendiff but SourceTree installer would be nice
		else
			_gimme meld
		fi
	;;
	tools)
		_gimme bash_profile liquidprompt git tmux tree vim
	;;
	dev+generic)
		_gimme gcc mergetool
	;;
	dev+js)
		_gimme node jshint js-beautify json
	;;
	dev+sh)
		_gimme shellcheck
	;;
	dev+py)
		_gimme python pylint pep8
	;;
	dev+db)
		_gimme mongodb redis postgresql
	;;
	dev+go)
		_gimme go
	;;
	dev)
		_gimme dev+generic dev+js dev+sh dev+py dev+db dev+go
	;;
	stuff)
		_gimme tools dev
	;;
	homebrew) _gimme gcc git
		[[ -d "$HOME/homebrew" ]]   ||  (mkdir "$HOME/homebrew" 2>/dev/null  &&  curl -L "https://github.com/Homebrew/homebrew/tarball/master" | tar xz --strip 1 -C "$HOME/homebrew"  &&  brew update)
		[[ "$BREW_PREFIX" ]]  ||  BREW_PREFIX=$(brew --prefix)
		has brew-cask  ||  brew install caskroom/cask/brew-cask
	;;
	pkgtool)
		if [[ "$OS" = "Darwin" ]]; then
			_gimme homebrew
		else
			has apt-get  ||  return 123
		fi
	;;
	pkgtool_metadata)
		pkgtool update
	;;
	gimme)
		echo "Checking gimme ..."
		_gimme git
		if ! [[ -d "$GIMME_DIR" ]]; then
			echo "Installing $HOME/bin/gimme ..."
			mkdir -p "$GIMME_DIR"
			git clone "$GIMME_URL" "$GIMME_DIR"
			mkdir -p "$HOME/bin"
			ln -sf "$GIMME_DIR/gimme.sh" "$HOME/bin/gimme"
		else
			echo "Updating gimme ..."
			pushd "$GIMME_DIR" >/dev/null
			git pull
			popd >/dev/null
		fi
	;;
	*)
		_gimme pkgtool
		#TODO: _gimme pkgtool_metadata
		has "$PKG"  ||  _gimmepkg "$PKG"
	;;
	esac
	echo "# DONE: gimme $PKG"
}

_gimme() {
	local PKG
	for PKG in "$@"; do
		if ! __gimme "$PKG"; then
			echo "ERROR: Unable to fulfill gimme for $PKG!"
			return 123
		fi
	done
}

gimme() {
	_GIMMES=
	#set -x
	_gimme "$@"
	#set +x
}

GIMME_GIMMES=$(type __gimme | grep ')$' | tr -d ')|*')
_gimme_complete() {
	COMPREPLY=( $(compgen -W "$GIMME_GIMMES" -- "${COMP_WORDS[COMP_CWORD]}") )
}
complete -F _gimme_complete gimme

if [[ ! "$BASH_SOURCE" && "$#" = 0 ]]; then
	gimme gimme
	exit 0
fi

gimme "$@"
