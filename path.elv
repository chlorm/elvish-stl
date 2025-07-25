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


use path
use ./env
use ./list
use ./platform
use ./re
use ./str


var DELIMITER = '/'
if $platform:is-windows {
    set DELIMITER = '\'
}

fn absolute {|path_|
    path:abs $path_
}

fn basename {|path_|
    path:base $path_
}

fn clean {|path_|
    path:clean $path_
}

fn dirname {|path_|
    path:dir $path_
}

fn dos2unix {|path|
    re:replace '[\\]' '/' $path
}

fn escape {|path_ &unix=$false &input=$false &invert=$false|
    fn -order {|a b|
        if $invert {
            put $b $a
        } else {
            put $a $b
        }
    }

    if (and $platform:is-windows (not $unix)) {  # DOS
        # WARNING: Improperly escaped strings can silently fail powershell functions
        var specialChars = [
            '['
            ']'
        ]
        var singleEscape = [
            '`'  # Must come first
            ''''
            ' '  # Space
            '('
            ')'
            '{'
            '}'
            ':'
            ','
            '&'
            ';'
            '$'
        ]
        var unicodeChars = [ (re:find '([^\x00-\x7F])' $path_) ]
        for i $unicodeChars {
            if (not (list:has $singleEscape $i)) {
                set singleEscape = [ $@singleEscape $i ]
            }
        }
        var doubleEscape = [ ]
        if $input {
            # Special characters have to be double escaped when passed as input.
            set doubleEscape = $specialChars
        } else {
            set singleEscape = [
                $@singleEscape
                $@specialChars
            ]
        }
        for i $doubleEscape {
            set path_ = (str:replace (-order $i '``'$i) $path_)
        }
        for i $singleEscape {
            set path_ = (str:replace (-order $i '`'$i) $path_)
        }
        put $path_
    } else {  # Unix-like
        # Git on Windows uses MSYS2, so it expects unix-like DOS paths.
        if $platform:is-windows {
            set path_ = (str:replace (-order '\' '\\') $path_)
            set path_ = (str:replace (-order ' ' '\ ') $path_)
        }
        put $path_
    }
}

fn escape-input {|path_|
    escape &input=$true $path_
}

fn escape-unixlike {|path_|
    escape &unix=$true $path_
}

fn ext {|path_|
    path:ext $path_
}

fn home {
    if $platform:is-windows {
        str:join '' [ (env:get 'HOMEDRIVE') (env:get 'HOMEPATH') ]
        return
    }

    env:get 'HOME'
}

# Walks up a path to see if any parent is hidden. (e.g. path/.hidden-file)
fn is-hidden {|path_|
    var hidden = $false
    var p = $path_
    while $true {
        if (str:has-prefix (basename $p) '.') {
            set hidden = $true
            break
        }
        set p = (dirname $p)
        # Root of path
        if (==s $p '.') {
            break
        }
    }
    put $hidden
}

fn join {|@pathObjects| path:join $@pathObjects }

# Converts an absolute path into a relative path.
fn relative-to {|absolutePath relativeToAbsolutePath|
    var p1 = $absolutePath
    var p2 = $relativeToAbsolutePath
    var p1Final = $nil
    var p2Iter = (num 1)
    # Recurse up p1 until p2 has-prefix p1
    while $true {
        if (str:has-prefix $p2 $p1) {
            set p1Final = $p1
            break
        }
        set p1 = (dirname $p1)
    }
    # Recurse up p2 til p2 == p1Final counting iterations
    while $true {
        if (==s $p1Final $p2) {
            break
        }
        set p2 = (dirname $p2)
        set p2Iter = (+ $p2Iter (num 1))
    }
    # Prepend ../'s of the number of iters
    var prepend = [ ]
    if (> $p2Iter 1) {
        for i [ (range 1 $p2Iter) ] {
            set prepend = [ $@prepend '..' ]
        }
    }
    if (and (!=s $p1Final '') (not (str:has $absolutePath $p1Final$DELIMITER))) {
        fail 'Mixed path separators'
    }
    join $@prepend (str:replace $p1Final$DELIMITER '' $absolutePath)
}

fn unescape {|path_|
    escape &invert=$true $path_
}

fn unescape-input {|path_|
    escape &invert=$true &input=$true $path_
}

fn unescape-unixlike {|path_|
    escape &invert=$true &unix=$true $path_
}

fn -scandir-glob {|directoryPath &type='regular'|
    # Extra trailing `/`, multiple `/` cause the remove root regex to fail.
    set directoryPath = (re:replace '[\/]+$' '/' $directoryPath)

    put $directoryPath*[nomatch-ok][match-hidden][type:$type] | peach {|i|
        # Remove root path
        set i = (re:replace '^'(re:quote $directoryPath) '' $i)
        # Convert path to native delimiters
        set i = (clean $i)
        put $i
    }
}

fn scandir {|directoryPath|
    # Elvish only supports globbing unix-like delimited paths.
    set directoryPath = (dos2unix $directoryPath)

    set directoryPath = $directoryPath'/'

    var files = [ ]
    var dirs = [ ]
    run-parallel {
        set files = [ (-scandir-glob $directoryPath) ]
    } {
        set dirs = [ (-scandir-glob &type='dir' $directoryPath) ]
    }

    put [
        &root=(clean $directoryPath)
        &dirs=$dirs
        &files=$files
    ]
}

fn walk {|directoryPath|
    var o = (scandir $directoryPath)
    put $o

    for d $o['dirs'] {
        var p = (join $o['root'] $d)
        walk $p
    }
}
