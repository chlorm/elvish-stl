use github.com/chlorm/elvish-stl/platform
use github.com/chlorm/elvish-stl/test
use github.com/chlorm/elvish-stl/windows

if (not $platform:is-windows) {
    echo 'skipping' >&2
    exit
}

test:assert { windows:reserved 'C:\NUL\dir' }
test:refute { windows:reserved 'C:\dir\NUL' }
