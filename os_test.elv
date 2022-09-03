use github.com/chlorm/elvish-stl/os
use github.com/chlorm/elvish-stl/platform
use github.com/chlorm/elvish-stl/test


# FIXME: non-hermetic
if $platform:is-unix {
    test:assert { os:stat '/' }
} else {
    test:assert { os:stat 'C:\' }
}

test:assert { os:is-file 'os.elv' }
test:refute { os:is-file 'not-existant-file' }

test:assert { os:exists 'os.elv' }
test:refute { os:exists 'not-existant-file' }

# FIXME: non-hermetic
test:assert { os:is-symlink '/bin' }

if $platform:is-windows {
    test:fail { os:touch 'NUL' }
}
