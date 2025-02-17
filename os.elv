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


use ./env
use ./exec
use ./map
use ./path
use ./platform
use ./str
use ./windows
use os os_


var NULL = $os_:dev-null

fn chmod {|perm target|
    os_:chmod "0o"$perm $target
}

# FIXME: windows port
fn chown {|user-group path|
    exec:cmd 'chown' '-v' $user-group $path
}

fn copy {|sourcePath targetPath|
    if $platform:is-windows {
        windows:reserved $targetPath
        exec:ps 'Copy-Item' ^
            '-LiteralPath' (path:escape (path:absolute $sourcePath)) ^
            '-Destination' (path:escape (path:absolute $targetPath))
        return
    }

    exec:cmd 'cp' '-v' $sourcePath $targetPath
}

# FIXME: windows port
fn gid {
    exec:cmd-out 'id' '-g'
}

fn link {|sourcePath targetPath|
    if $platform:is-windows {
        windows:reserved $targetPath
        exec:ps 'New-Item' '-ItemType' 'HardLink' ^
            '-Value' (path:escape-input (path:absolute $sourcePath)) ^
            '-Path' (path:escape (path:absolute $targetPath))
        return
    }

    exec:cmd 'ln' '-v' $sourcePath $targetPath
}

fn makedir {|directoryPath|
    os_:mkdir $directoryPath
}

fn makedirs {|directoryPath|
    os_:mkdir-all $directoryPath
}

fn move {|sourcePath targetPath|
    if $platform:is-windows {
        windows:reserved $targetPath
        exec:ps 'Move-Item' ^
            '-LiteralPath' (path:escape (path:absolute $sourcePath)) ^
            '-Destination' (path:escape (path:absolute $targetPath))
        return
    }

    exec:cmd 'mv' '-v' $sourcePath $targetPath
}

fn readlink {|path|
    if $platform:is-windows {
        exec:ps-out 'Get-Item' $path '|' ^
            'Select-Object' '-ExpandProperty' 'Target'
        return
    }

    exec:cmd-out 'readlink' '-f' $path
}

fn remove {|filePath|
    os_:remove $filePath
}

fn removedirs {|directoryPath|
    os_:remove-all $directoryPath
}

# FIXME: implement icacl/fsutil windows port, only permission should differ.
fn stat {|path &fs=$false|
    # FIXME: birth-time and selinux-context are not portable.
    var def = [
        &permission-octal='%a'
        &filetype='%F'
        &gid='%g'
        &size='%s'
        &uid='%u'
        &access-time='%x'
        &modification-time='%y'
        &status-change-time='%z'
    ]
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
    }

    # Build format string
    var tmp = [ ]
    for i [ (map:keys $def) ] {
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
    var s = (exec:cmd-out 'stat' $@cmdArgs $path)
    set s = [ (str:split ',' $s) ]

    if (not (eq (count $tmp) (count $s))) {
        fail 'list length mismatch'
    }

    var stat = [&]
    var iter = 0
    for i [ (map:keys $def) ] {
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
        if (!=s $type (os_:stat $path)[type]) {
            fail
        }
    } catch _ {
        set i = $false
    }
    put $i
}

fn is-blkdev {|path| -is-type 'device' $path }
fn is-chardev {|path| -is-type 'chardevice' $path }
fn is-dir {|path| os_:is-dir $path }
fn is-file {|path| os_:is-regular $path }
fn is-pipe {|path| -is-type 'named-pipe' $path }
fn is-socket {|path| -is-type 'socket' $path }
fn is-symlink {|path| -is-type 'symlink' $path }
fn is-unknown {|path| -is-type 'irregular' $path }
fn exists {|path| os_:exists $path }

# NOTE: Symlinks require admin permissions on Windows.
fn symlink {|sourcePath targetPath|
    os_:symlink $sourcePath $targetPath
}

fn touch {|filePath|
    if $platform:is-windows {
        windows:reserved $filePath
        exec:ps 'New-Item' '-ItemType' 'file' ^
            '-Path' (path:escape-input (path:absolute $filePath))
        return
    }

    exec:cmd 'touch' $filePath
}

# FIXME: windows port
fn uid {
    exec:cmd-out 'id' '-u'
}

fn unlink {|linkPath|
    if $platform:is-windows {
        remove $linkPath
        return
    }

    exec:cmd 'unlink' $linkPath
}

fn user {
    if $platform:is-windows {
        env:get 'UserName'
        return
    }

    exec:cmd-out 'id' '-un'
}
