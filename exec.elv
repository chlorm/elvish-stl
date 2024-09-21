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
use ./io
use ./platform
use ./re
use ./str


# Captures and returns command errors while suppressing output on success.
# NOTE: This is intended for unix commands that have separate stdout/stderr.
fn cmd {|cmd @args &output=$false &line-delimiter=$nil|
    if (eq $line-delimiter $nil) {
        set line-delimiter = $str:LINE-DELIMITER
    }

    var stdout = (file:pipe)
    var stderr = (file:pipe)
    try {
        var c = (external $cmd)
        $c $@args >$stdout 2>$stderr
        file:close $stderr[w]
        file:close $stdout[w]
        file:close $stderr[r]
        if $output {
            var f = (io:open $stdout)
            # Remove trailing newlines
            var s = (re:replace $line-delimiter"$" '' $f)
            str:split $line-delimiter $s
        }
        # TODO: log output, allows using verboase output of commands
        file:close $stdout[r]
    } catch exception {
        try { file:close $stdout[w] } catch _ { }
        file:close $stdout[r]
        try { file:close $stderr[w] } catch _ { }
        var error = ''
        try {
            set error = (io:open $stderr)
            file:close $stderr[r]
        } catch _ { }
        var c = $cmd" "(str:join ' ' $args)
        var e = (to-string $exception['reason'])
        var errorMessage = "\n"$c"\n\n"$e"\n\n"$error
        fail $errorMessage
    }
}

# Captures and returns command errors and output.
fn cmd-out {|cmd @args|
    cmd &output=$true $cmd $@args
}

# Commands that return errors on stdout.
fn cmd-stdouterr {|cmd @args &output=$false &line-delimiter=$nil|
    if (eq $line-delimiter $nil) {
        set line-delimiter = $str:LINE-DELIMITER
    }

    var stdout = (file:pipe)
    try {
        var c = (external $cmd)
        $c $@args >$stdout
        file:close $stdout[w]
        if $output {
            var f = (io:open $stdout)
            # Remove trailing newlines
            var s = (re:replace $line-delimiter"$" '' $f)
            str:split $line-delimiter $s
        }
        file:close $stdout[r]
    } catch exception {
        try { file:close $stdout[w] } catch _ { }
        var error = ''
        try {
            set error = (io:open $stdout)
            file:close $stdout[r]
        } catch _ { }
        var c = $cmd" "(str:join ' ' $args)
        var e = (to-string $exception['reason'])
        var errorMessage = "\n"$c"\n\n"$e"\n\n"$error
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
