#!/bin/sh

# This script expects $1 to be passed and for $1 to be the filesystem location
# to a json file for which it will run syntax checks against.

syntax_errors=0
script_name=$(basename ${0})
error_msg=$(mktemp /tmp/error_msg_${script_name}.XXXXX)

if [ $2 ]; then
    module_path=$(echo $1 | sed -e 's|'$2'||')
else
    module_path=$1
fi

# Check json file syntax
echo "$(tput setaf 6)Checking json syntax for $module_path...$(tput sgr0)"
ruby -e "require 'rubygems'; require 'json'; JSON.parse(File.read('$1'))" 2> $error_msg > /dev/null
if [ $? -ne 0 ]; then
    cat $error_msg | sed -e "s/^/$(tput setaf 1)/" -e "s/$/$(tput sgr0)/"
    syntax_errors=`expr $syntax_errors + 1`
    echo "$(tput setaf 1)Error: json syntax error in $module_path (see above)$(tput sgr0)"
fi
rm -f $error_msg

if which metadata-json-lint > /dev/null 2>&1; then
    if [[ "$(basename $1)" == 'metadata.json' ]]; then
        metadata-json-lint $1 2> $error_msg  >&2
        if [ $? -ne 0 ]; then 
            cat $error_msg | sed -e "s/^/$(tput setaf 1)/" -e "s/$/$(tput sgr0)/"
            syntax_errors=`expr $syntax_errors + 1`
            echo "$(tput setaf 1)Error: json syntax error in $module_path (see above)$(tput sgr0)"
        fi
    fi
fi

if [ "$syntax_errors" -ne 0 ]; then
    echo
    echo "$(tput setaf 1)*** Commit will be aborted.$(tput sgr0)"
    exit 1
fi

exit 0
