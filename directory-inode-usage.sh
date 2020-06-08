#!/bin/sh
#
# Expose directory inode usage, passed as an argument.
#
# Usage: add this to crontab:
#
# */5 * * * * prometheus directory-inode-usage.sh /var/lib/prometheus | sponge /var/lib/node_exporter/directory_inode_usage.prom
#
# Author: Mike Nichols <c0psrul3@gmail.com>
echo "# HELP node_directory_inode_usage iNodes used by one directory"
echo "# TYPE node_directory_inode_usage gauge"

_device=$(df --output=source $@ 2>/dev/null | tail -n +2)
_mountpoint=$(df --output=target $@ 2>/dev/null | tail -n +2)

[[ -n $_device ]] && [[ -n $_mountpoint ]] \
    && du -x --inodes --summarize "$@" 2>/dev/null \
    | awk -v d="$_device" -v m="$_mountpoint" '{
        printf("node_directory_inode_usage{device=\"%s\",mountpoint=\"%s\",directory=\"%s\"} %d\n",d,m,$2,$1)
    }'

