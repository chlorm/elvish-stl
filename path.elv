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
use github.com/chlorm/elvish-stl/env
use github.com/chlorm/elvish-stl/list
use github.com/chlorm/elvish-stl/platform
use github.com/chlorm/elvish-stl/re
use github.com/chlorm/elvish-stl/str


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
        # WARNING: Improperly escaped strings fail powershell functions
        #          silently for an unknown reason.
        # FIXME: this is missing characters that need to be escaped.
        var specialChars = [
            '['
            ']'
        ]
        var single = [
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
        var unicodeQuoteFinalPunctuationChars = [ (re:find '\p{Pf}' $path_) ]
        for i $unicodeQuoteFinalPunctuationChars {
            if (not (list:has $single $i)) {
                set single = [ $@single $i ]
            }
        }
        var double = [ ]
        if $input {
            # Special characters have to be double escaped when passed as input.
            set double = $specialChars
        } else {
            set single = [
                $@single
                $@specialChars
            ]
        }
        for i $double {
            set path_ = (str:replace (-order $i '``'$i) $path_)
        }
        for i $single {
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

fn home {
    if $platform:is-windows {
        str:join '' [ (env:get 'HOMEDRIVE') (env:get 'HOMEPATH') ]
    } else {
        env:get 'HOME'
    }
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

fn join {|@objects|
    clean (str:join $DELIMITER $objects)
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

fn -scandir-glob {|dirPath &type='regular'|
    put $dirPath*[nomatch-ok][match-hidden][type:$type] | peach {|i|
        # Remove root path
        set i = (re:replace '^'$dirPath '' $i)
        # Convert path to native delimiters
        set i = (clean $i)
        put $i
    }
}

fn scandir {|dirPath|
    # Elvish only supports globbing unix-like delimited paths.
    set dirPath = (dos2unix $dirPath)

    # Append path delimiter to prevent globbing partial directory names.
    set dirPath = $dirPath'/'

    var files = [ ]
    var dirs = [ ]
    run-parallel {
        set files = [ (-scandir-glob $dirPath) ]
    } {
        set dirs = [ (-scandir-glob &type='dir' $dirPath) ]
    }

    put [
        &root=(clean $dirPath)
        &dirs=$dirs
        &files=$files
    ]
}

fn walk {|dirPath|
    var o = (scandir $dirPath)
    put $o

    for d $o['dirs'] {
        walk (join $o['root'] $d)
    }
}
