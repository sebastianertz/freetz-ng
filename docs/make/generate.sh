#! /usr/bin/env bash
# generates docs/make/README.md and make/README.md (subs)
MDPWD="$(dirname $(realpath $0))"
INPWD="$MDPWD/../../make/pkgs"

PKGS=$(
for dir in avm $(find "$INPWD" -maxdepth 1 -mindepth 1 -type d); do
	pkg="${dir##*/}"
	echo "$pkg" | grep -qE "^(busybox|libs|linux)$" && continue
	cat="$(sed -n 's/^$(PKG)_CATEGORY *:= *//p' $dir/$pkg.mk 2>/dev/null)"
	echo "${cat:-000Packages}##$pkg"
done | sort )

echo '[//]: # ( Do not edit this file! Run generate.sh to create it. )' > "$INPWD/README.md"
echo -n "Content: " >> "$INPWD/README.md"
echo "$PKGS" | sed 's/##.*//g' | uniq | sed 's/^000//' | while read cat; do echo -n "[$cat](#$(echo ${cat,,} | sed 's/ /-/g')) - "; done | sed 's/...$//' >> "$INPWD/README.md"
echo "$PKGS" | sed 's/##.*//g' | uniq | while read cat; do
	echo -e "\n# ${cat//0}"
	[ -z "$CTN" ] && CTN="Index: " && for x in $(echo {A..Z}); do CTN="$CTN[$x](#${x,,}) - "; done && echo ${CTN:0:-3}
	echo "$PKGS" | sed -n "s/^${cat}##//p" | while read pkg; do
		[ "${cat:0:3}" == "000" ] && [ "${pkg:0:1}" != "$IDX" ] && IDX="${pkg:0:1}" && echo -e "\n### ${IDX^^}"

		dsc="$(sed -rn 's/[ \t]*bool "([^\"]*)"[ \t]*.*/\1/p' "$INPWD/$pkg/Config.in" 2>/dev/null | head -n1)"
		[ "$pkg" == "mod" ] && dsc="Freetz(-MOD)"
		[ "$pkg" == "avm" ] && dsc="AVM Services"
		[ -z "$dsc" ] && echo "ignored: $pkg" 1>&2 && continue
		[ "${dsc//[ _]/-}" != "$(echo "${dsc//[ _]/-}" | sed "s/^${pkg//_/-}//I")" ] && itm="$dsc" || itm="$pkg: $dsc"

		grep -q '^### [A-Z]*:=http' "$INPWD/$pkg/$pkg.mk" 2>/dev/null && touch "$MDPWD/$pkg.md"
		if [ -e "$MDPWD/$pkg.md" ]; then
			while [ "$(awk 'END{print NR}' "$MDPWD/$pkg.md")" -lt 2 ]; do echo >> "$MDPWD/$pkg.md"; done
			sed "1c# $dsc" -i "$MDPWD/$pkg.md"

			sed "/^  - Maintainer: .*$/d" -i "$MDPWD/$pkg.md"
			lnk="$(sed -n "s/^### SUPPORT:= *//p" "$INPWD/$pkg/$pkg.mk")"
			case "$lnk" in
				X)	lnk="" ;;
				"")	lnk="-" ;;
				*)	[ "$lnk" != "${lnk/:\/\//}" ] && lnk="\[$lnk\]($lnk)" || lnk="\[@$lnk\](https://github.com/$lnk)" ;; #"
			esac
			[ -n "$lnk" ] && sed "2i\  - Maintainer: $lnk" -i "$MDPWD/$pkg.md"

			lnk="https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/$pkg/"
			sed "/^  - Package: \[.*)$/d" -i "$MDPWD/$pkg.md"
			sed "2i\  - Package: \[${lnk:44}\]($lnk)" -i "$MDPWD/$pkg.md"

			for pair in CVSREPO°Repository CHANGES°Changelog MANPAGE°Manpage WEBSITE°Homepage; do
				sed "/^  - ${pair#*°}: \[.*)$/d" -i "$MDPWD/$pkg.md"
				lnk="$(sed -n "s/^### ${pair%%°*}:= *//p" "$INPWD/$pkg/$pkg.mk")"
				[ -n "$lnk" ] && sed "2i\  - ${pair#*°}: \[$lnk\]($lnk)" -i "$MDPWD/$pkg.md"
			done
			itm="[$itm](../../docs/make/$pkg.md)"
			lst="$(sed -n 's/^### //p' "$MDPWD/$pkg.md" | grep -v ' Links$')"
		else
			itm="<u>$itm</u>"
			lst=''
		fi
		anc="${pkg//_/-}"
		echo -e "\n  * **$itm<a id='${anc%-cgi}'></a>**<br>"

		L="$(grep -P '^[ \t]*help[ \t]*$' -nm1 "$INPWD/$pkg/Config.in" 2>/dev/null | sed 's/:.*//')"
		C="$(wc -l "$INPWD/$pkg/Config.in" 2>/dev/null | sed 's/ .*//')"
		[ -z "$L" -o -z "$C" ] && echo "nohelp1: $pkg" 1>&2 && continue
		T=$(( $C - $L))
		N="$(tail -n "$T" "$INPWD/$pkg/Config.in" | grep -P "^[ \t]*(#|(end)*if|config|bool|string|int|depends on|(end)*menu|comment|menuconfig|(end)*choice|prompt|select|default|source|help)($|\t| )" -n | head -n1 | sed 's/:.*//')"
		help="$(tail -n "$T" "$INPWD/$pkg/Config.in" | head -n "$(( ${N:-99} - 1 ))" | grep -vP '^[ \t]*$' | sed 's/[ \t]*$//g;s/^[ \t]*//g;s/$/ /g' | tr -d '\n' | sed 's/ $//')"
		[ -z "$help" ] && echo "nohelp2: $pkg" 1>&2 || echo "    $help"

		[ -n "$lst" ] && echo "$lst" | while read line; do echo "     - [$line](../../docs/make/$pkg.md#$(echo "$line" | sed -re 's/(.*)/\L\1/;s/[ _]/-/g;s/[^-0-9a-z]//g'))"; done

	done
done >> "$INPWD/README.md"
grep -v '^     - ' "$INPWD/README.md" | sed 's,](../../docs/make/,](,g' > "$MDPWD/README.md"

