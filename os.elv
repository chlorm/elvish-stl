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


var NULL = '/dev/null'
if $platform:is-windows {
    set NULL = 'NUL'
}

# https://docs.microsoft.com/en-us/windows/win32/fileio/naming-a-file#naming-conventions
var WINDOWS-RESERVED-NAMES = [
    'AUX'
    'COM1'
    'COM2'
    'COM3'
    'COM4'
    'COM5'
    'COM6'
    'COM7'
    'COM8'
    'COM9'
    'CON'
    'LPT1'
    'LPT2'
    'LPT3'
    'LPT4'
    'LPT5'
    'LPT6'
    'LPT7'
    'LPT8'
    'LPT9'
    'NUL'
    'PRN'
]

fn -check-windows-reserved [path]{
    var b = (path:basename $path)
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
    e:id '-g'
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
    e:mkdir '-p' $dir
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
    e:readlink '-m' $path
}

fn remove [file]{
    e:rm '-f' $file
}

fn removedirs [dir]{
    e:rm '-fr' $dir
}

fn stat [path &fs=$false]{
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
    var s = [ (str:split ',' (e:stat $@cmdArgs $path)) ]

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

fn statfs [path]{
    stat &fs=$true $path
}

fn -is-type [type path]{
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

fn is-blkdev [path]{ -is-type 'block device' $path }
fn is-chardev [path]{ -is-type 'character device' $path }
fn is-dir [path]{ -is-type 'directory' $path }
fn is-file [path]{ -is-type 'regular file' $path }
fn is-pipe [path]{ -is-type 'FIFO/pipe' $path }
fn is-socket [path]{ -is-type 'socket' $path }
fn is-symlink [path]{ -is-type 'symbolic link' $path }
fn is-unknown [path]{ -is-type 'unknown?' $path }
fn exists [path]{
    try {
        var _ = (> (count (stat $path 2>&-)) 0)
        put $true
    } except _ {
        put $false
    }
}

fn symlink [source target]{
    if $platform:is-windows {
        -check-windows-reserved $target
    }
    e:ln '-s' $source $target
}

fn touch [target]{
    if $platform:is-windows {
        -check-windows-reserved $target
    }
    e:touch $target
}

fn uid {
    e:id '-u'
}

fn unlink [link]{
    e:unlink $link
}

fn user {
    e:id '-un'
}
