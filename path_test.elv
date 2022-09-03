use github.com/chlorm/elvish-stl/path
use github.com/chlorm/elvish-stl/test


# Trailing delimiter should not cause paths to differ
test:assert-bool {
    var p1 = (path:scandir ../elvish-stl)
    var p2 = (path:scandir ../elvish-stl/)
    eq $p1 $p1
}

test:assert-bool {
    ==s ^
        (path:relative-to $E:HOME/.config/elvish $E:HOME/.local) ^
        '../.config/elvish'
}
test:assert-bool {
    ==s ^
        (path:relative-to $E:HOME/.local $E:HOME/.config/elvish) ^
        '../../.local'
}
