#!/usr/bin/zsh
# The CGI Support file for zsh.
#
# Table of Contents:
# 1 HTML Tags
# 1.1 Basic & Core
# 1.2 Block Elems
# 1.3 Oneline Elems
# 1.4 Self-closed Elems
# 2 Deal with Queries
# 2.1 Get & Post

# 1 HTML TAGS

# 1.1 Basic & Core

mkhead() {
        # Make the head of doc
	mkreq "text/html; charset=UTF-8"
	print '<!doctype html>'
	Html
	Head
	[[ -n "$title" ]] && Title "$title"
	[[ -n "$css" ]] && Css "$css"
	[[ -n "$headelse" ]] && print "$headelse"
	endHead
	Body
}
mkreq() {
	# Raise Mimetype
	MIME="$*"
	print "Content-type: $MIME\n"
}
mkfoot() {
	# Make the foot of doc
	[[ -n "$footer" ]] && echo "$footer"
	endBody
	endHtml
}
Css() {
	Link --rel=stylesheet --type=text/css --href=$1
}

###### CORE
cargs() {
	# Core function: convert a POSIX command-line to variables
	local value=
	attrs= tag= content=
	for arg in "$@"; do
		case "$arg" in
			--?*\=?*)
				attr=${arg#--}
				value=${attr#*\=}
				attr=${attr%%\=*}
				attrs+=" $attr=\"$value\""
			;;
			--?*)
				tag="${arg#--}"
			;;
			*)
				content+="$arg"
			;;
		esac
	done
}
######/CORE

# 1.2 Block Elems
# like <div>
#		...
#	   </div>

Begin() {
	# Begining of a `block' elem.
	cargs "$@"
	[[ -z "$tag" ]] && tag=div
	echo "<$tag$attrs>"
}
End() {
	# Ending of a `block' elem
	cargs "$@"
	[[ -z "$tag" ]] && tag=div
	echo "</$tag>"
}
genBlockBegin() {
	for x in "$@"; do
		X=${(C)x}
		eval "$X()"'{Begin --'"$x"' $@;}'
	done
}
genBlockEnd() {
	for x in "$@"; do
		X=${(C)x}
		eval "end$X()"'{End --'"$x"' $@;}'
	done
}
genBlock() {
	for x in "$@"; do
		genBlockBegin "$x"
		genBlockEnd "$x"
	done
}
genBlock html head body div table tr thead tfoot form dl ol ul address blockquote pre script style fieldset textarea
# For HTML5 #
genBlock article section header nav footer datalist details audio video

# 1.3 Oneline Elems
# like <p>...</p>

Oneline() {
	cargs "$@"
	[[ -z "$tag" ]] && tag=p
	echo "<$tag$attrs>$content</$tag>"
}
genOneline() {
	for x in "$@"; do
		X=${(C)x}
		eval "$X()"'{Oneline --'"$x"' $@;}'
	done
}
genOneline p th td strong em code kbd samp cite dfn var li a abbr caption dt dd title ins del a button label legend h1 h2 h3 h4 h5 h6
# For HTML5 #
genOneline summary

# 1.4 Self-closed Elems
# like <br />
SelfClose() {
	cargs "$@"
	[[ -z "$tag" ]] && tag=br
	echo "<$tag$attrs />"
}
genSelfClose() {
	for x in "$@"; do
		X=${(C)x}
		eval "$X()"'{SelfClose --'"$x"' $@;}'
	done
}
genSelfClose br img link input hr

# 2 DEAL WITH QUERIES

# 2.1 Get & Post

# Get the POST Data.
if [[ -p /dev/stdin || -f /dev/stdin ]]; then
	export POST_STRING="$(< /dev/stdin)"
fi
readGET() {
	[[ -z "$QUERY_STRING" ]] && return 1
	typeset -Agx GET
	get=(${(s:&:)QUERY_STRING}) # remove &
	for i in $get; do
		j=(${(s:=:)i})
		GET+=($j)
	done
}
readPOST() {
	[[ -z "$POST_STRING" ]] && return 1
	typeset -Agx POST
	post=(${(s:&:)POST_STRING}) # remove &
	for i in $post; do
		j=(${(s:=:)i})
		POST+=($j)
	done
}
uconv() {
	# Convert %xx expression to real chars.
	local text="$*"
	local output="${text/+/ }" # + -> ' '
	local output="${output//\%/\\x}"
	echo "$output"
}

# 3 Other Things

# 3.1 Modules

# Z Module Loading, discard the `zsh/' prefix
useZ() {
	for m in "$@"; do
		zmodload "zsh/$m"
	done
}
# by default, we only load the mathfunc package.

# Sub Files
source /lib/zcu2_math.zsh

# ZSHINFO
zshINFO() {
	title="ZSH Information"
	mkhead
	h1 "ZSH Information"
	table
	row
		th "Version"
		td $ZSH_VERSION
	endrow
	row
		th "Path"
		td $PATH
	endrow
	row
		th "Operating System"
		td $OSTYPE
	endrow
	row
		th "CPU"
		td $PROCESSOR_IDENTIFIER
	endrow
	row
		th "Path"
		td $PATH
	endrow
	endtable
	pre
	set
	endpre
	mkfoot
	exit
}
