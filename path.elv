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


use file
use path
use platform
use str
use github.com/chlorm/elvish-stl/list


var DELIMITER = '/'
if $platform:is-windows {
    set DELIMITER = '\'
}

# This wrapper captures and returns powershell errors while suppressing output
# on success.
fn -wrap-powershell [@command]{
    var p = (file:pipe)
    try {
        e:powershell.exe '-NonInteractive' '-Command' $@command >$p
        file:close $p[w]
        put (str:split "\r\n" (slurp < $p))
        file:close $p[r]
    } except _ {
        file:close $p[w]
        var e = (slurp < $p)
        file:close $p[r]
        fail $e
    }
}

fn absolute [path_]{
    path:abs $path_
}

fn basename [path_]{
    path:base $path_
}

fn home {
    if $platform:is-windows {
        put (str:join '' [ (get-env 'HOMEDRIVE'; get-env 'HOMEPATH') ])
    } else {
        get-env 'HOME'
    }
}

fn join [@objects]{
    put (path:clean (str:join $DELIMITER $objects))
}

fn dirname [path_]{
    path:dir $path_
}

fn scandir [dir]{
    # Remove path escapes, see comment below
    if $platform:is-windows {
        set dir = (str:replace '` ' ' ' $dir)
    }

    var p = $pwd
    try {
        cd $dir
    } except _ {
        fail 'directory does not exist: '$dir
    }
    cd $p

    # Windows uses ` to escape spaces in paths.
    # This must come after cd because elvish's internal cd escapes paths
    # automatically.
    if $platform:is-windows {
        set dir = (str:replace ' ' '` ' $dir)
    }

    # find returns an empty string for matches that have been filtered out.
    fn -non-empty [@s]{
        for i $s {
            if (!=s '' $i) {
                put $i
            }
        }
    }

    var findFiles = [ ]
    if $platform:is-windows {
        set findFiles = [(
            -wrap-powershell 'Get-ChildItem' '-Path' $dir '-File' '-Name'
        )]
    } else {
        set findFiles = [(
            e:find $dir '-maxdepth' 1 '-not' '-type' 'd' '-printf' '%P\n'
        )]
    }
    var files = [ (-non-empty $@findFiles) ]
    var findDirs = [ ]
    if $platform:is-windows {
        set findDirs = [(
            -wrap-powershell 'Get-ChildItem' '-Path' $dir '-Directory' '-Name'
        )]
    } else {
        set findDirs = [(
            e:find $dir '-maxdepth' 1 '-type' 'd' '-printf' '%P\n'
        )]
    }
    var dirs = [ (-non-empty $@findDirs) ]

    put [
        &root=$dir
        &dirs=$dirs
        &files=$files
    ]
}

# NOTE: this is not performant
fn walk [dir]{
    var dirSearch = [ $dir ]
    while (> (count $dirSearch) 0) {
        for s $dirSearch {
            # Update index
            set dirSearch = (list:drop $dirSearch $s)

            var o = (scandir $s)
            var root = (path:clean $o['root'])

            put [
                &root=$root
                &dirs=$o['dirs']
                &files=$o['files']
            ]

            # Append new directories to index
            for f $o[dirs] {
                set dirSearch = [ $@dirSearch (join $root $f) ]
            }
        }
    }
}
