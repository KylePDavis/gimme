#!/bin/bash
# A micro meta package manager for the masses.
# USAGE:
#     gimme [stuff]
###############################################################################

[ "$GIMME_URL" ]         ||  export GIMME_URL="http://git.kylepdavis.com/kylepdavis/gimme"
[ "$GIMME_DIR" ]         ||  export GIMME_DIR="$HOME/.gimme"
[ "$GIMME_GIMMES_DIR" ]  ||  export GIMME_GIMMES_DIR="$GIMME_DIR/gimmes"
[ "$GIMME_LINK" ]        ||  export GIMME_LINK="$HOME/bin/gimme"
[ "$GIMME_LINK_DIR" ]    ||  export GIMME_LINK_DIR=$(dirname "$GIMME_LINK")
[ "$GIMMES" ]            ||  export GIMMES=""
[ "$OS" ]                ||  export OS=$(uname -s)
[ "$DEBUG" ]             ||  export DEBUG=0

has() { which "$1" >/dev/null; }

pkgtool() {
	if [[ "$OS" = "Darwin" ]]; then
		brew "$@"
	else
		sudo apt-get -y "$@"
	fi
}

gimme_pkg() {
	pkgtool install "$@"
}

export -f has pkgtool gimme_pkg


if [[ "$0" = "bash" ]]; then # sourced or piped

	if [[ "$BASH_SOURCE" ]]; then # sourced

		_gimme_completely() {
			if [[ "$2" = -* ]]; then
				COMPREPLY=( $(compgen -W "--help --version" -- "$2") )
			else
				COMPREPLY=( $(find "$GIMME_GIMMES_DIR" -type f -path "$GIMME_GIMMES_DIR/$2*" \! -name '.*' -printf "%P\n") )
			fi
		}

		complete -F _gimme_completely gimme

	else # piped

		if ! [[ -d "$GIMME_DIR" ]]; then

			echo "Installing $GIMME_DIR/gimme ..."
			mkdir -p "$GIMME_DIR"
			git clone "$GIMME_URL" "$GIMME_DIR"
			mkdir -p "$(dirname "$GIMME_LINK")"
			ln -sf "$GIMME_DIR/gimme" "$GIMME_LINK"
			echo "Done! Now you can 'gimme stuff' or 'gimme dev/stuff' or even 'gimme gimme'!"

		else

			echo "Updating gimme (in $GIMME_DIR) ..."
			cd "$GIMME_DIR"
			git pull

		fi

	fi

else # normal usage
	set -e
	set -E
	set -o pipefail

	on_err() {
		echo "ERROR: Unable to gimme \"$GIMME\" (EXIT=$?)" 1>&2
	}
	trap on_err ERR

	for GIMME; do

		! [[ "$GIMMES" == *" $GIMME "* ]]  ||  exit 0
		export GIMMES+=" $GIMME " GIMME

		P="$GIMME_GIMMES_DIR/$GIMME"

		if ! [[ -f "$P" ]]; then
			# find _default handler
			while P=$(dirname "$P") && [[ "$P" = "$GIMME_GIMMES_DIR"* ]]; do
				if [[ -f "$P/_default" ]]; then
					P="$P/_default"
					break;
				fi
			done
			# no default
			if ! [[ "$P" = "$GIMME_GIMMES_DIR"* ]]; then
				echo "# ERROR: Unable to find $GIMME_GIMMES_DIR/_default handler" 1>&2
				exit 1
			fi
		fi

		if [[ -x "$P" ]]; then
			[[ "$PATH" = "$LINK_DIR"* ]]  ||  export PATH="$LINK_DIR:$PATH"
			"$P"
			echo "# DONE: gimme $GIMME"
		else
			echo "# WARN: gimme $GIMME was SKIPPED because $P is not marked executable!"
		fi

	done
fi
