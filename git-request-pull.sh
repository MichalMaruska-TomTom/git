#!/bin/sh -e
# Copyright 2005, Ryan Anderson <ryan@michonline.com>
#
# This file is licensed under the GPL v2, or a later version
# at the discretion of Linus Torvalds.

USAGE='<start> <url> [<end>]'
LONG_USAGE='Summarizes the changes between two commits to the standard output,
and includes the given URL in the generated summary.'
SUBDIRECTORY_OK='Yes'
OPTIONS_SPEC=
. git-sh-setup
. git-parse-remote

GIT_PAGER=
export GIT_PAGER

base=$1
url=$2
head=${3-HEAD}

[ "$base" ] || usage
[ "$url" ] || usage

baserev=`git rev-parse --verify "$base"^0` &&
headrev=`git rev-parse --verify "$head"^0` || exit

merge_base=`git merge-base $baserev $headrev` ||
die "fatal: No commits in common between $base and $head"

branch=$(git ls-remote "$url" \
	| sed -n -e "/^$headrev	refs.heads./{
		s/^.*	refs.heads.//
		p
		q
	}")
url=$(get_remote_url "$url")
if [ -z "$branch" ]; then
	echo "warn: No branch of $url is at:" >&2
	git log --max-count=1 --pretty='tformat:warn:   %h: %s' $headrev >&2
	echo "warn: Are you sure you pushed $head there?" >&2
	echo >&2
	echo >&2
	branch=..BRANCH.NOT.VERIFIED..
	status=1
fi

echo "The following changes since commit $baserev:"
git shortlog --max-count=1 $baserev | sed -e 's/^\(.\)/  \1/'

echo "are available in the git repository at:"
echo
echo "  $url $branch"
echo

git shortlog ^$baserev $headrev
git diff -M --stat --summary $merge_base $headrev
exit $status
