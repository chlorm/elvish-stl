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


null = '/dev/null'
if $platform:is-windows {
    null = 'NUL'
}

fn chmod [perm target]{
    e:chmod $perm $target
}

fn chown [user-group target]{
    e:chown $user-group $target
}

fn copy [source target]{
    e:cp $source $target
}

fn gid {
    e:id -g
}

fn link [source target]{
    e:ln $source $target
}

fn makedir [dir]{
    e:mkdir $dir
}

fn makedirs [dir]{
    e:mkdir -p $dir
}

fn move [source target]{
    e:mv $source $target
}

# Returns dos or unix
fn ostype {
    if (==s '\' $path:delimiter) {
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
    local:def = [ ]
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
    local:tmp = [ ]
    for local:i [ (keys $def) ] {
        tmp = [ $@tmp $def[$i] ]
    }
    local:fmt = (str:join "," $tmp)

    local:args = [ '-c' $fmt ]
    if $fs {
        args = [ $@args '-f' ]
    }
    # The so called parsable(terse) output places the path (not parsable if path
    # contains a space) first and the final element (SELinux) is dynamic so
    # manually specify the format string to actually get parsable output.
    local:s = [ (str:split ',' (e:stat $@args $path)) ]

    if (not (eq (count $tmp) (count $s))) {
        fail 'list length mismatch'
    }

    local:stat = [&]
    local:iter = 0
    for local:i [ (keys $def) ] {
        stat[$i]=$s[$iter]
        iter = (+ $iter 1)
    }

    put $stat
}

fn statfs [path]{
    stat &fs=$true $path
}

fn -is-type [type path]{
    local:i = $true
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
    if ?(stat $path >$null 2>&-) { put $true } else { put $false }
}

fn symlink [source target]{
    e:ln -s $source $target
}

fn touch [target]{
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
