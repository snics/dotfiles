kraken () {
	/Applications/GitKraken.app/Contents/MacOS/GitKraken -p "$(git rev-parse --show-toplevel)" &>/dev/null &
}
