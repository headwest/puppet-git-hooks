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
echo "Checking json syntax for $module_path..."
ruby -e "require 'rubygems'; require 'json'; JSON.parse(File.read('$1'))" 2> $error_msg > /dev/null
if [ $? -ne 0 ]; then
    cat $error_msg
    syntax_errors=`expr $syntax_errors + 1`
    echo "Error: json syntax error in $module_path (see above)"
fi
rm -f $error_msg

if which metadata-json-lint > /dev/null 2>&1; then
    if [[ "$(basename $1)" == 'metadata.json' ]]; then
        metadata-json-lint $1 2> $error_msg  >&2
        if [ $? -ne 0 ]; then
            cat $error_msg
            syntax_errors=`expr $syntax_errors + 1`
            echo "Error: json syntax error in $module_path (see above)"
        fi
    fi
fi

if [ "$syntax_errors" -ne 0 ]; then
    echo
    echo "*** Commit will be aborted."
    exit 1
fi

exit 0
