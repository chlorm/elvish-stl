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


use ./env
use ./os
use ./path
use ./str


# env-var is a comma separated environment variable of preferred commands.
# fallbackCmds is a list of fallback commands if none exist in env-var.
fn get-preferred-cmd {|envVar fallbackCmds|
    var cmds = $fallbackCmds
    try {
        set cmds = [ $@cmds (str:split ',' (env:get $envVar)) ]
    } catch _ { }

    var cmdsStr = (to-string $cmds)

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
        var err = 'No command found in '$cmds', install one or set '$envVar
        fail $err
    }

    put $cmd
}

fn is-nil {|val|
    if (eq $val $nil) {
        put $true
        return
    }

    str:is-empty $val
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
