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


use ./list
use ./path
use ./platform
use ./re
use ./str
use ./utils


var DELIMITER = ':'
if $platform:is-windows {
    set DELIMITER = ';'
}

fn get {|envVar|
    try {
        get-env $envVar
    } catch e {
        var err = (to-string $e['reason'])': '$envVar
        fail $err
    }
}

fn get-value-or-nil {|envVar|
    try {
        var t = (get-env $envVar)
        if (utils:is-nil $t) {
            fail
        }
        put $t
    } catch _ {
        put $nil
    }
}

fn has {|envVar|
    bool ?(var _ = (get-env $envVar))
}

fn set {|envVar value|
    try {
        set-env $envVar $value
    } catch e {
        var err = (to-string $e['reason'])': '$envVar'='$value
        fail $err
    }
}

fn unset {|envVar|
    unset-env $envVar
}

fn -delimiter-valid {|delimiter|
    if (==s $delimiter '') {
        fail 'Cannot delimit path by empty string'
    } elif (eq $delimiter $nil) {
        fail 'Cannot delimit path by $nil'
    }
}

fn has-elem {|envVar elem &delimiter=':'|
    var envVarVal = (get-value-or-nil $envVar)
    if (eq $envVarVal $nil) {
        put $false
        return
    }

    -delimiter-valid $delimiter
    list:has [ (str:split $delimiter $envVarVal) ] $elem
}

# Generic append/prepend
fn -pend-generic {|envVar path &delimiter=$nil &pre=$false|
    var envVarVal = (get-value-or-nil $envVar)
    if (eq $envVarVal $nil) {
        set-env $envVar $path
        return
    }

    if (has-elem $envVar $path &delimiter=$delimiter) {
        # Don't pollute paths with duplicates.
        return
    }

    if $pre {
        set-env $envVar $path$delimiter$envVarVal
        return
    }

    set-env $envVar $envVarVal$delimiter$path
}

fn append {|envVar path &delimiter=':'|
    -pend-generic $envVar $path &delimiter=$delimiter &pre=$false
}

fn prepend {|envVar path &delimiter=':'|
    -pend-generic $envVar $path &delimiter=$delimiter &pre=$true
}

fn bin-path {|bin|
    var path = $nil
    try {
        set path = (search-external $bin)
    } catch _ {
        fail
    }

    if (or (eq $path $nil) (==s $path '')) {
        fail
    }

    if $platform:is-windows {
        # search-external does not escape paths
        set path = (path:escape $path)
        # Windows does not require file extensions for executables in the
        # search path.
        set path = (re:replace '\.exe$' '' $path)
    }

    put $path
}
