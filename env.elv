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


use str
use github.com/chlorm/elvish-stl/list


fn get-value-or-nil [envVar]{
    var envVarVal = $nil
    try {
        set envVarVal = (get-env $envVar)
        if (or (eq $envVarVal $nil)
               (==s $envVarVal '')) {
            fail
        }
        put $envVarVal
    } except _ {
        put $envVarVal
    }
}

fn -delimiter-valid [delimiter]{
    if (==s $delimiter '') {
        fail 'Cannot delimit path by empty string'
    } elif (eq $delimiter $nil) {
        fail 'Cannot delimit path by $nil'
    }
}

fn has-path [envVar path &delimiter=':']{
    var envVarVal = (get-value-or-nil $envVar)
    if (eq $envVarVal $nil) {
        put $false
        return
    }

    -delimiter-valid $delimiter
    put (list:contains [ (str:split $delimiter $envVarVal) ] $path)
}

# Generic append/prepend
fn -pend-generic [envVar path &delimiter=$nil &pre=$false]{
    var envVarVal = (get-value-or-nil $envVar)
    if (eq $envVarVal $nil) {
        set-env $envVar $path
        return
    }

    # Don't pollute paths with duplicates.
    if (has-path $envVar $path &delimiter=$delimiter) {
        return
    }

    if $pre {
        set-env $envVar $path$delimiter$envVarVal
    } else {
        set-env $envVar $envVarVal$delimiter$path
    }
}

fn append [envVar path &delimiter=':']{
    -pend-generic $envVar $path &delimiter=$delimiter &pre=$false
}

fn prepend [envVar path &delimiter=':']{
    -pend-generic $envVar $path &delimiter=$delimiter &pre=$true
}
