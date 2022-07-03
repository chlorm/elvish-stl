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


use re
use str
use github.com/chlorm/elvish-stl/list
use github.com/chlorm/elvish-stl/path
use github.com/chlorm/elvish-stl/platform


fn exists {|envVar|
    bool ?(var _ = (get-env $envVar))
}

fn get-value-or-nil {|envVar|
    try {
        var t = (get-env $envVar)
        if (re:match '^([\s]+)?$' $t) {
            fail
        }
        put $t
    } catch _ {
        put $nil
    }
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
    } elif (has-elem $envVar $path &delimiter=$delimiter) {
        # Don't pollute paths with duplicates.
        return
    } elif $pre {
        set-env $envVar $path$delimiter$envVarVal
    } else {
        set-env $envVar $envVarVal$delimiter$path
    }
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

    # search-external does not escape paths
    if $platform:is-windows {
        set path = (path:escape $path)
    }

    put $path
}
