# Copyright (c) 2020-2021, Cody Opel <cwopel@chlorm.net>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


use path path_
use str
use github.com/chlorm/elvish-stl/path
use github.com/chlorm/elvish-stl/platform
use github.com/chlorm/elvish-stl/windows
use github.com/chlorm/elvish-stl/wrap


var NULL = '/dev/null'
if $platform:is-windows {
    set NULL = 'NUL'
}

# FIXME: windows port
fn chmod {|perm target|
    wrap:cmd 'chmod' '-v' $perm $target
}

# FIXME: windows port
fn chown {|user-group target|
    wrap:cmd 'chown' '-v' $user-group $target
}

fn copy {|source target|
    if $platform:is-windows {
        windows:reserved $target
        wrap:ps 'Copy-Item' ^
            '-Path' (path:escape-input (path:absolute $source)) ^
            '-Destination' (path:escape $target)
    } else {
        wrap:cmd 'cp' '-v' $source $target
    }
}

# FIXME: windows port
fn gid {
    wrap:cmd-out 'id' '-g'
}

fn link {|source target|
    if $platform:is-windows {
        windows:reserved $target
        wrap:ps 'New-Item' '-ItemType' 'HardLink' ^
            '-Value' (path:escape-input (path:absolute $source)) ^
            '-Path' (path:escape $target)
    } else {
        wrap:cmd 'ln' '-v' $source $target
    }
}

fn makedir {|dir|
    if $platform:is-windows {
        windows:reserved $dir
        # FIXME: fail if parent doesn't exist, New-Item always creates parents.
        wrap:ps 'New-Item' '-ItemType' 'directory' ^
            '-Path' (path:escape-input (path:absolute $dir))
    } else {
        wrap:cmd 'mkdir' '-v' $dir
    }
}

fn makedirs {|dir|
    if $platform:is-windows {
        windows:reserved $dir
        wrap:ps 'New-Item' '-ItemType' 'directory' ^
            '-Path' (path:escape-input (path:absolute $dir))
    } else {
        wrap:cmd 'mkdir' '-pv' $dir
    }
}

fn move {|source target|
    if $platform:is-windows {
        windows:reserved $target
        wrap:ps 'Move-Item' ^
            '-Path' (path:escape-input (path:absolute $source)) ^
            '-Destination' (path:escape $target)
    } else {
        wrap:cmd 'mv' '-v' $source $target
    }
}

# Returns dos or unix
fn ostype {
    if (==s $path:DELIMITER '\') {
        put 'dos'
    } else {
        put 'unix'
    }
}

fn readlink {|path|
    path:absolute (path_:eval-symlinks $path)
}

fn remove {|file|
    if $platform:is-windows {
        wrap:ps 'Remove-Item' '-Force' '-Confirm:$False' ^
            '-Path' (path:escape-input (path:absolute $file))
    } else {
        wrap:cmd 'rm' '-fv' $file
    }
}

fn removedirs {|dir|
    if $platform:is-windows {
        wrap:ps 'Remove-Item' '-Recurse' '-Force' '-Confirm:$False' ^
            '-Path' (path:escape-input (path:absolute $dir))
    } else {
        wrap:cmd 'rm' '-frv' $dir
    }
}

# FIXME: implement icacl/fsutil windows port, only permission should differ.
fn stat {|path &fs=$false|
    var def = [&]
    if $fs {
        set def = [
            &blocks='%b'
            &inodes='%c'
            &available-blocks='%a'
            &free-blocks='%f'
            &free-inodes='%d'
            &id='%i'
            &max-filename-length='%l'
            &block-size='%s'
            &fundamental-block-size='%S'
            &type-hex='%t'
            &type='%T'
        ]
    } else {
        # FIXME: birth-time and selinux-context are not portable.
        set def = [
            &permission-octal='%a'
            &filetype='%F'
            &gid='%g'
            &size='%s'
            &uid='%u'
            &access-time='%x'
            &modification-time='%y'
            &status-change-time='%z'
        ]
    }

    # Build format string
    var tmp = [ ]
    for i [ (keys $def) ] {
        set tmp = [ $@tmp $def[$i] ]
    }
    var fmt = (str:join "," $tmp)

    var cmdArgs = [ '-c' $fmt ]
    if $fs {
        set cmdArgs = [ $@cmdArgs '-f' ]
    }
    # The so called parsable(terse) output places the path (not parsable if path
    # contains a space) first and the final element (SELinux) is dynamic so
    # manually specify the format string to actually get parsable output.
    var s = [ (str:split ',' (wrap:cmd-out 'stat' $@cmdArgs $path)) ]

    if (not (eq (count $tmp) (count $s))) {
        fail 'list length mismatch'
    }

    var stat = [&]
    var iter = 0
    for i [ (keys $def) ] {
        set stat[$i] = $s[$iter]
        set iter = (+ $iter 1)
    }

    put $stat
}

fn statfs {|path|
    stat &fs=$true $path
}

fn -is-type {|type path|
    var i = $true
    try {
        if (!=s $type (stat $path 2>&-)[filetype]) {
            fail
        }
    } except _ {
        set i = $false
    }
    put $i
}

fn is-blkdev {|path| -is-type 'block device' $path }
fn is-chardev {|path| -is-type 'character device' $path }
fn is-dir {|path| -is-type 'directory' $path }
fn is-file {|path| -is-type 'regular file' $path }
fn is-pipe {|path| -is-type 'FIFO/pipe' $path }
fn is-socket {|path| -is-type 'socket' $path }
fn is-symlink {|path| -is-type 'symbolic link' $path }
fn is-unknown {|path| -is-type 'unknown?' $path }
fn exists {|path|
    try {
        var _ = (> (count (stat $path)) 0)
        put $true
    } except _ {
        put $false
    }
}

# NOTE: Symlinks require admin permissions on Windows.
fn symlink {|source target|
    if $platform:is-windows {
        windows:reserved $target
        wrap:ps 'New-Item' '-ItemType' 'SymbolicLink' ^
            '-Value' (path:escape-input (path:absolute $source)) ^
            '-Path' (path:escape $target)
    } else {
        wrap:cmd 'ln' '-sv' $source $target
    }
}

fn touch {|target|
    if $platform:is-windows {
        windows:reserved $target
        wrap:ps 'New-Item' '-ItemType' 'file' ^
            '-Path' (path:escape-input (path:absolute $target))
    } else {
        wrap:cmd 'touch' $target
    }
}

# FIXME: windows port
fn uid {
    wrap:cmd-out 'id' '-u'
}

fn unlink {|link|
    if $platform:is-windows {
        remove $link
    } else {
        wrap:cmd 'unlink' $link
    }
}

fn user {
    if $platform:is-windows {
        wrap:ps-out '$env:UserName'
    } else {
        wrap:cmd-out 'id' '-un'
    }
}
