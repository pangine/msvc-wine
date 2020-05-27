#!/bin/bash
EXE=$1
shift
ARGS=()
while [ $# -gt 0 ]; do
	a=$1
	case $a in
	/*)
		if [ -d "$(dirname $a)" ] && [ "$(dirname $a)" != "/" ]; then
			a=z:$a
		fi
		;;
	*)
		;;
	esac
	ARGS+=("$a")
	shift
done
wine "$EXE" "${ARGS[@]}" 2> >(sed '/^[[:alnum:]]*:\?fixme/d; /^err:bcrypt:hash_init/d; s/\r$//' >&2) | sed 's/z:\([\\/]\)/\1/i; s/\r$//'
exit $PIPESTATUS
