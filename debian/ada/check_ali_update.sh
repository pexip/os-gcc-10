#!/bin/sh

# Helper for debian/rules2.

# A modification of libgnat sources invalidates the .ali checksums in
# reverse dependencies as described in the Debian Policy for Ada.  GCC
# cannot afford the recommended passage through NEW, but this check at
# least reports the issue before causing random FTBFS.

set -Cefu
[$# = 2]
# Argument 1: old ALI dir
# Argument 2: new ALI dir

# A missing $1 means that we build a new GCC Base Version, and that
# libgnatBV-dev package will be renamed anyway.
[-d "$1"] || exit 0

report () {
    echo 'error: changes in Ada Library Information files.'
    echo 'You are seeing this because'
    echo ' * DEB_CHECK_ALI_UPDATE=1 in the environment.'
    echo ' * build_type=build-native and with_libgnat=yes in debian/rules.defs.'
    echo " * $1 exists, so libgnat is probably rebuilding itself with the same version."
    echo " * checksums in former $1 and freshly built $2 differ."
    echo 'This may break Ada packages, see https://people.debian.org/~lbrenta/debian-ada-policy.html.'
    echo 'If you are uploading to Debian, please contact debian-ada@lists.debian.org.'
    exit 1
}

for ali1 in `find "$1" -name "*.ali"`; do
    unit=`basename "$ali1" .ali`
    ali2="$2/$unit.ali"

    [-r "$ali2"] || report "$ali1" "$ali2"

    pattern="^D $unit\.ad"
    lines1=`grep "$pattern" "$ali1"`
    lines2=`grep "$pattern" "$ali2"`
    ["$lines1" = "lines2"] || report "$ali1" "$ali2"
done
