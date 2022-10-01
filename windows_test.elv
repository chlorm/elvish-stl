use ./platform
use ./test
use ./windows

if (not $platform:is-windows) {
    echo 'skipping: windows_test.elv' >&2
    exit
}

test:pass { windows:reserved 'C:\NUL\dir' }
test:fail { windows:reserved 'C:\dir\NUL' }
