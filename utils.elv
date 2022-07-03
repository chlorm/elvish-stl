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


use str
use github.com/chlorm/elvish-stl/env
use github.com/chlorm/elvish-stl/os
use github.com/chlorm/elvish-stl/path
use github.com/chlorm/elvish-stl/re


# env-var is a comma separated environment variable of preferred commands.
# cmds is a list of fallback commands if none exist in env-var.
fn get-preferred-cmd {|envVar cmds|
    var orig = (to-string $cmds)

    try {
        var cmds = [ (str:split ',' (get-env $envVar)) ]
    } catch _ { }

    var cmd = $nil
    for i $cmds {
        var path = $nil
        try {
            set path = (env:bin-path $i)
        } catch _ {
            continue
        }
        set cmd = $path
        break
    }

    if (eq $cmd $nil) {
        var err = 'No command found in '$orig', install one or set '$envVar
        fail $err
    }

    put $cmd
}

fn test-writeable {|dir|
    try {
        var file = (path:join $dir 'test-write-file')
        if (os:exists $file) {
            os:remove $file
        }
        os:touch $file
        os:remove $file
    } catch _ {
        var err = $dir' is not writeable'
        fail $err
    }
}
