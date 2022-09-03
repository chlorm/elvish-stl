use github.com/chlorm/elvish-stl/os
use github.com/chlorm/elvish-stl/platform
use github.com/chlorm/elvish-stl/test


# FIXME: non-hermetic
if $platform:is-unix {
    test:assert-bool { os:stat '/' }
} else {
    test:assert-bool { os:stat 'C:\' }
}

test:assert-bool { os:is-file 'os.elv' }
test:refute-bool { os:is-file 'not-existant-file' }

test:assert-bool { os:exists 'os.elv' }
test:refute-bool { os:exists 'not-existant-file' }

# FIXME: non-hermetic
test:assert-bool { os:is-symlink '/bin' }

if $platform:is-windows {
    test:refute { os:touch 'NUL' }
}
