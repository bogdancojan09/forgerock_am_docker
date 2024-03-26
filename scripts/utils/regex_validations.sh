#!/usr/bin/env bash

# Validate if a string follows a specific pattern
# Usage: is_pattern <string> <pattern>
# Example: 8080 is a number, 8024 is a number, aaa has small letters only
is_pattern() {
    if [[ $1 =~ $2 ]] ; then
        echo "true"
    else
        echo "false"
    fi
}
