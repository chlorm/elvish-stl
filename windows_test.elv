use github.com/chlorm/elvish-stl/platform
use github.com/chlorm/elvish-stl/test
use github.com/chlorm/elvish-stl/windows

if (not $platform:is-windows) {
    echo 'skipping' >&2
    exit
}

test:pass { windows:reserved 'C:\NUL\dir' }
test:fail { windows:reserved 'C:\dir\NUL' }
