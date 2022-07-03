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
use github.com/chlorm/elvish-stl/io
use github.com/chlorm/elvish-stl/platform
use github.com/chlorm/elvish-stl/re
use github.com/chlorm/elvish-stl/str


# Captures and returns command errors while suppressing output on success.
# NOTE: This is intended for unix commands that have separate stdout/stderr.
fn cmd {|cmd @args &output=$false|
    var stdout = (file:pipe)
    var stderr = (file:pipe)
    try {
        var c = (external $cmd)
        $c $@args >$stdout 2>$stderr
        file:close $stderr[w]
        file:close $stdout[w]
        file:close $stderr[r]
        if $output {
            str:split "\n" (re:replace "\n$" '' (io:open $stdout))
        }
        # TODO: log output, allows using verboase output of commands
        file:close $stdout[r]
    } catch exception {
        file:close $stdout[w]
        file:close $stdout[r]
        file:close $stderr[w]
        var error = (io:open $stderr)
        file:close $stderr[r]
        var errorMessage = (to-string $exception['reason'])"\n\n"$error
        fail $errorMessage
    }
}

# Captures and returns command errors and output.
fn cmd-out {|cmd @args|
    cmd &output=$true $cmd $@args
}

# Commands that return errors on stdout.
fn cmd-stdouterr {|cmd @args &output=$false|
    var stdout = (file:pipe)
    try {
        var c = (external $cmd)
        $c $@args >$stdout
        file:close $stdout[w]
        if $output {
            var s = "\n"
            if $platform:is-windows {
                set s = "\r"$s
            }
            str:split $s (re:replace $s"$" '' (io:open $stdout))
        }
        file:close $stdout[r]
    } catch exception {
        file:close $stdout[w]
        var error = (io:open $stdout)
        file:close $stdout[r]
        var errorMessage = (to-string $exception['reason'])"\n\n"$error
        fail $errorMessage
    }
}

# Captures and returns powershell errors while suppressing output on success.
fn ps {|@psCode &cmd='powershell'|
    cmd-stdouterr $cmd '-NonInteractive' '-Command' $@psCode
}

# Captures and returns powershell errors and output.
fn ps-out {|@psCode &cmd='powershell'|
    cmd-stdouterr &output=$true $cmd '-NonInteractive' '-Command' $@psCode
}
