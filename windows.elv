# Copyright (c) 2021, Cody Opel <cwopel@chlorm.net>
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
use str
use github.com/chlorm/elvish-stl/path


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

fn check-reserved [path]{
    var b = (path:basename $path)
    for i $WINDOWS-RESERVED-NAMES {
        if (==s $i (str:to-upper $b)) {
            fail 'Windows reserved name: '$i
        }
    }
}

# This wrapper captures and returns powershell errors while optionally
# suppressing output on success.
fn wrap-powershell [@command &output=$false]{
    var p = (file:pipe)
    try {
        e:powershell.exe '-NonInteractive' '-Command' $@command >$p
        file:close $p[w]
        if $output {
            put (str:split "\r\n" (slurp < $p))
        }
        file:close $p[r]
    } except _ {
        file:close $p[w]
        var e = (slurp < $p)
        file:close $p[r]
        fail $e
    }
}
