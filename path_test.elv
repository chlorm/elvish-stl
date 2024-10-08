use ./path
use ./test


# Trailing delimiter should not cause paths to differ
test:assert {
    var p1 = (path:scandir ../elvish-stl)
    var p2 = (path:scandir ../elvish-stl/)
    eq $p1 $p1
}

test:assert {
    ==s ^
        (path:relative-to $E:HOME'/.config/elvish' $E:HOME'/.local') ^
        '../.config/elvish'
}
test:assert {
    ==s ^
        (path:relative-to $E:HOME'/.local' $E:HOME'/.config/elvish') ^
        '../../.local'
}

test:assert {
    var path_ = "File with \u0085 a next line control char.mp4"
    var escaped = (path:escape-input $path_)
    ==s $escaped "File` with` `\u0085` a` next` line` control` char.mp4"
}
