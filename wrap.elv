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
use re
use str


# Captures and returns powershell errors while optionally suppressing output
# on success.
fn powershell [@cmd &output=$false]{
    var out = (file:pipe)
    try {
        e:powershell.exe '-NonInteractive' '-Command' $@cmd >$out
        file:close $out[w]
        if $output {
            put (str:split "\r\n" (re:replace "\r\n$" '' (slurp < $out)))
        }
        file:close $out[r]
    } except _ {
        file:close $out[w]
        var e = (slurp < $out)
        file:close $out[r]
        fail $e
    }
}

# Captures and returns cmd errors while optionally suppressing output on
# success.
fn unix [cmd @args &output=$false]{
    var stdout = (file:pipe)
    var stderr = (file:pipe)
    try {
        var c = (external $cmd)
        $c $@args >$stdout 2>$stderr
        file:close $stderr[w]
        file:close $stdout[w]
        file:close $stderr[r]
        if $output {
            put (str:split '\n' (re:replace '\n$' '' (slurp < $stdout)))
        }
        file:close $stdout[r]
    } except _ {
        file:close $stdout[w]
        file:close $stdout[r]
        file:close $stderr[w]
        var error = (slurp < $stderr)
        file:close $stderr[r]
        fail $error
    }
}
