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


use github.com/chlorm/elvish-stl/exec
use github.com/chlorm/elvish-stl/path
use github.com/chlorm/elvish-stl/str


# https://docs.microsoft.com/en-us/windows/win32/fileio/naming-a-file#naming-conventions
var RESERVED-NAMES = [
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

fn reserved {|path|
    var b = (path:basename $path)
    for i $RESERVED-NAMES {
        if (==s $i (str:to-upper $b)) {
            var err = 'Windows reserved name: '$i
            fail $err
        }
    }
}

fn is-admin {
    var b = (exec:ps-out ^
        '[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")')
    if (==s $b 'True') {
        put $true
    } else {
        put $false
    }
}
