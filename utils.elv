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
use github.com/chlorm/elvish-stl/os
use github.com/chlorm/elvish-stl/path


# env-var is a comma separated environment variable of preferred commands.
# cmds is a list of fallback commands if none exist in env-var.
fn get-preferred-cmd [env-var cmds]{
    local:cmd = ''
    try {
        for local:i [ (str:split ',' (get-env $env-var)) ] {
            cmd = (search-external $i)
            if (!=s '' $cmd) {
                break
            }
        }
    } except _ {
        for local:p $cmds {
            try {
                cmd = (search-external $p)
                break
            } except _ {
                continue
            }
        }
    }

    if (==s $cmd '') {
        fail 'No command found in '$cmds', install one or set '$env-var
    }

    put $cmd
}

fn test-writeable [dir]{
    try {
        local:file = (path:join $dir 'test-write-file')
        if (os:exists $file) {
            os:remove $file
        }
        os:touch $file
        os:remove $file
    } except _ {
        fail $dir' is not writeable'
    }
}
