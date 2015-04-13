#!/bin/sh
#
#    rnc2rng.sh: a script for converting compact form RelaxNG to XML
#                with trang.
#
#    Copyright (C) 2014 VyOS Development Group <maintainers@vyos.net>
#
#    This library is free software; you can redistribute it and/or
#    modify it under the terms of the GNU Lesser General Public
#    License as published by the Free Software Foundation; either
#    version 2.1 of the License, or (at your option) any later version.
#
#    This library is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#    Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public
#    License along with this library; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
#    USA

which trang 2>&1 >/dev/null
if [ $? != 0 ]; then
    echo "trang binary not found"
    echo "Install trang (http://www.thaiopensource.com/relaxng/trang.html)"
    echo "or make sure it is in your $PATH"
    exit 1
fi

compile_one() {
    local src=$1
    local dst=$2
    if [ ! -f "$src" ]; then
        echo "Source file $src does not exist"
        exit 1
    fi
    if [ -z "$dst" ]; then
        echo "Please specify destination file"
        exit 1
    fi

    echo "Writing RelaxNG from $src to $dst"
    trang -Irnc -Orng $src $dst
}

# Loop over all .rnc files in a directory compiling
# them to .rng with the same name and new extension
compile_all_in_path() {
    local path=$1
    if [ ! -d "$path"  ]; then
        echo "Directory $path was not found"
        exit 1
    fi

    schemas=$(find $path -type f -name '*.rnc')

    for schema in $schemas; do
        compile_one $schema $(echo $schema | sed 's/\.rnc$/.rng/g')
    done
}

case $1 in
    all)
        path=${SCHEMAS_PATH:-$2}
        echo "Compiling all rnc schemas in $path"
        compile_all_in_path "$path"
    ;;
    one)
        compile_one $2 $3
    ;;
    *)
        echo "Usage:"
        echo "$0 all <path>: compiles all rnc schemas in <path> to rng"
        echo "$0 one <source> <destination>: compiles rnc <source> to rng <destination>"
    ;;
esac
