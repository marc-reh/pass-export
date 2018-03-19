#!/bin/bash

# pass export, a password store extension
#
# Copyright (c) 2018 Marc Rehmsmeier
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


version="1.0"

show_version() {
    cat <<EOF
$PROGRAM $COMMAND $version
EOF
}

show_usage() {
    show_version
    echo
    cat <<EOF
Usage:
    $PROGRAM export [-h] [-v] [-V] export-name target-repo
        Export passwords specified in export-name.export to target-repo

        export-name.export is a user-provided file in ~/.password-store
        (unless this default is overridden by the environment variable
        PASSWORD_STORE_DIR, see pass(1) man page).

        export-name.export lists passwords or directories to be exported,
        e.g.:

        Email/my_email.com
        Banking

        A single dot ('.') specifies the export of all passwords from the
        password store.

        At the moment, pass-export's only functionality is to export
        specified passwords to a git repository target-repo. If target-repo
        does not exist, pass-export asks whether it should create it (as a
        bare repository).

    Options:
        -h, --help    Print this help message and exit
        -v, --verbose Show all git output
        -V, --version Show version information and exit

EOF
}

check_git_repos() {
    if [ ! -e "${git_repo}" ]; then
	read -r -p "Export git repository does not exist. Shall I create it? [y/N] " response
	case ${response} in
	    [yY])
		echo "OK."
		eval "git init --bare ${git_repo} ${git_redirect}"
	    	;;
	    *)
		echo "Aborting." >&2
		exit 1
	esac
        # https://stackoverflow.com/a/3232082

    elif [ ! -d "${git_repo}" ] ||
	$( cd "${git_repo}"; ! git rev-parse --git-dir > /dev/null 2>&1 ); then
	echo "${git_repo} is not a git repository. Aborting." >&2
	exit 1
        # https://stackoverflow.com/a/2185353

    elif ! $( cd "${PREFIX}"; git diff-index --quiet HEAD -- ); then
        echo "${PREFIX} has uncomitted changes. Aborting" >&2
	exit 1
        # https://stackoverflow.com/a/41646552
    fi
}

collect_gpg_files() {
    IFS=$'\n'
    while read -r line || [ -n "$line" ]; do
	pattern=${PREFIX}/${line}
	if [ -e "${pattern}.gpg" ]; then
	    [ -z "${gpgfiles}" ] && gpgfiles=${pattern}.gpg ||
	    gpgfiles=${gpgfiles}$'\n'${pattern}.gpg
	elif [ -d "${pattern}" ]; then
	    files=$(find "${pattern}" -name '*.gpg')
	    for f in ${files}; do
		gpgfiles=${gpgfiles}$'\n'${f}
	    done
	else
	    echo "${line} is not a password file nor a password directory; I'll skip this" >&2
	fi
    done < ${export_file}
}


export_passwords() {
    IFS=$'\n'

    echo "exporting passwords ..."

    cd ${PREFIX}
    branchname=$(uuidgen)
    eval "git branch ${branchname} ${git_redirect}"
    eval "git checkout ${branchname} ${git_redirect}"

    if $( cd ${git_repo}; git show-ref > /dev/null 2>&1 ); then
	eval "git pull ${git_repo} ${git_redirect}"
    fi

    eval "git rm '*.gpg' ${git_redirect}"

    for f in ${gpgfiles}; do
	eval "git checkout master ${f} ${git_redirect}"
    done

    output=$(git commit -m 'export' 2>&1)
    eval "echo \"${output}\" ${git_redirect}"
    if [[ "${output}" =~ "nothing added to commit" ]]; then
	echo "no changes"
    else
	printf "${output}" | grep changed
	eval "git push ${git_repo} ${branchname}:master ${git_redirect}"
    fi
    
    eval "git checkout master ${git_redirect}"
    eval "git branch -D ${branchname} ${git_redirect}"

    echo "done"
}


# parse options:
# (adapted from https://stackoverflow.com/a/4300224)

short_opts="hvV"
long_opts="help,verbose,version"

${GETOPT} -T > /dev/null
if [ $? -eq 4 ]; then
  # GNU enhanced getopt is available
  args=`${GETOPT} --long ${long_opts} --options ${short_opts} -- "$@"`
else
  # Original getopt is available (no long option names, no whitespace, no sorting)
  args=`${GETOPT} ${short_opts} "$@"`
fi
if [ $? -ne 0 ]; then
  echo "${PROGRAM} ${COMMAND}: usage error (use -h for help)" >&2
  exit 1
fi
eval set -- $args

git_redirect='> /dev/null 2>&1'

while [ $# -gt 0 ]; do
    case "$1" in
	-h|--help)
	    show_usage
	    exit 0
	    ;;
	-v|--verbose)
	    git_redirect=''
	    ;;
	-V|--version)
	    show_version
	    exit 0
	    ;;
	--)
	    shift
	    break
	    ;;
    esac
    shift
done

if [ $# -lt 2 ]; then
    echo "${PROGRAM} ${COMMAND}: usage error: too few arguments given (use -h for help)" >&2
    exit 1
elif [ $# -gt 2 ]; then
    echo "${PROGRAM} ${COMMAND}: usage error: too many arguments given (use -h for help)" >&2
    for arg in $@; do
	echo ${arg}
    done
    exit
fi

# assign arguments:
export_file=${PREFIX}/${1}.export
git_repo=`cd $(dirname ${2}); pwd`/`basename ${2}`

check_git_repos

gpgfiles=''
collect_gpg_files

export_passwords

