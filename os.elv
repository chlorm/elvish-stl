# Copyright (c) 2020, Cody Opel <cwopel@chlorm.net>
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


use platform
use str
use github.com/chlorm/elvish-stl/path


NULL = '/dev/null'
if $platform:is-windows {
    NULL = 'NUL'
}

# https://docs.microsoft.com/en-us/windows/win32/fileio/naming-a-file#naming-conventions
WINDOWS-RESERVED-NAMES = [
    AUX
    COM1
    COM2
    COM3
    COM4
    COM5
    COM6
    COM7
    COM8
    COM9
    CON
    LPT1
    LPT2
    LPT3
    LPT4
    LPT5
    LPT6
    LPT7
    LPT8
    LPT9
    NUL
    PRN
]

fn -check-windows-reserved [path]{
    b = (path:basename $path)
    for i $WINDOWS-RESERVED-NAMES {
        if (==s $i (str:to-upper $b)) {
            fail 'Windows reserved name: '$i
        }
    }
}

fn chmod [perm target]{
    e:chmod $perm $target
}

fn chown [user-group target]{
    e:chown $user-group $target
}

fn copy [source target]{
    if $platform:is-windows {
        -check-windows-reserved $target
    }
    e:cp $source $target
}

fn gid {
    e:id -g
}

fn link [source target]{
    if $platform:is-windows {
        -check-windows-reserved $target
    }
    e:ln $source $target
}

fn makedir [dir]{
    if $platform:is-windows {
        -check-windows-reserved $dir
    }
    e:mkdir $dir
}

fn makedirs [dir]{
    if $platform:is-windows {
        -check-windows-reserved $dir
    }
    e:mkdir -p $dir
}

fn move [source target]{
    if $platform:is-windows {
        -check-windows-reserved $target
    }
    e:mv $source $target
}

# Returns dos or unix
fn ostype {
    if (==s $path:DELIMITER '\') {
        put 'dos'
    } else {
        put 'unix'
    }
}

fn readlink [path]{
    e:readlink -m $path
}

fn remove [file]{
    e:rm -f $file
}

fn removedirs [dir]{
    e:rm -fr $dir
}

fn stat [path &fs=$false]{
    def = [&]
    if $fs {
        def = [
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
        def = [
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
    tmp = [ ]
    for i [ (keys $def) ] {
        tmp = [ $@tmp $def[$i] ]
    }
    fmt = (str:join "," $tmp)

    cmdArgs = [ '-c' $fmt ]
    if $fs {
        cmdArgs = [ $@cmdArgs '-f' ]
    }
    # The so called parsable(terse) output places the path (not parsable if path
    # contains a space) first and the final element (SELinux) is dynamic so
    # manually specify the format string to actually get parsable output.
    s = [ (str:split ',' (e:stat $@cmdArgs $path)) ]

    if (not (eq (count $tmp) (count $s))) {
        fail 'list length mismatch'
    }

    stat = [&]
    iter = 0
    for i [ (keys $def) ] {
        stat[$i] = $s[$iter]
        iter = (+ $iter 1)
    }

    put $stat
}

fn statfs [path]{
    stat &fs=$true $path
}

fn -is-type [type path]{
    i = $true
    try {
        if (!=s $type (stat $path 2>&-)[filetype]) {
            fail
        }
    } except _ {
        i = $false
    }
    put $i
}

fn is-blkdev [path]{ -is-type 'block device' $path }
fn is-chardev [path]{ -is-type 'character device' $path }
fn is-dir [path]{ -is-type 'directory' $path }
fn is-file [path]{ -is-type 'regular file' $path }
fn is-pipe [path]{ -is-type 'FIFO/pipe' $path }
fn is-socket [path]{ -is-type 'socket' $path }
fn is-symlink [path]{ -is-type 'symbolic link' $path }
fn is-unknown [path]{ -is-type 'unknown?' $path }
fn exists [path]{
    if ?(stat $path >$NULL 2>&-) { put $true } else { put $false }
}

fn symlink [source target]{
    if $platform:is-windows {
        -check-windows-reserved $target
    }
    e:ln -s $source $target
}

fn touch [target]{
    if $platform:is-windows {
        -check-windows-reserved $target
    }
    e:touch $target
}

fn uid {
    e:id -u
}

fn unlink [link]{
    e:unlink $link
}

fn user {
    e:id -un
}
