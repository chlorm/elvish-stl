# Copyright (c) 2020-2022, Cody Opel <cwopel@chlorm.net>
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


use builtin
use ./path
use ./str


fn run {
    var files = (path:scandir $pwd)

    var failures = 0
    for file $files[files] {
        if (str:has-suffix $file '_test.elv') {
            echo 'Running: '$file >&2
            try {
                e:elvish $file
            } catch _ {
                set failures = (+ $failures 1)
            }
        }
    }

    if (> $failures 0) {
        if (== $failures 1) {
            builtin:fail '1 test failed'
        }
        builtin:fail $failures' tests failed'
    }
}

fn pass {|closure~|
    printf 'pass: %s' $closure~['def']
    try {
        $closure~
    } catch e {
        printf ", %s\n" (styled 'failed' red)
        builtin:fail $e
    }
    printf ", %s\n" (styled 'passed' green)
}

fn fail {|closure~|
    printf 'fail: %s' $closure~['def']
    try {
        var r = (assert $closure~)
        if (not $r) {
            builtin:fail
        }
    } catch _ {
        printf ", %s\n" (styled 'passed' green)
        return
    }
    printf ", %s\n" (styled 'failed' red)
    builtin:fail
}

fn assert {|assertion~|
    printf 'assert: %s' $assertion~['def']
    try {
        if (not ($assertion~)) {
            builtin:fail
        }
    } catch e {
        printf ", %s\n" (styled 'failed' red)
        builtin:fail $e
    }
    printf ", %s\n" (styled 'passed' green)
}

fn refute {|assertion~|
    printf 'refute: %s' $assertion~['def']
    try {
        if ($assertion~) {
            builtin:fail
        }
    } catch e {
        printf ", %s\n" (styled 'failed' red)
        builtin:fail $e
    }
    printf ", %s\n" (styled 'passed' green)
}
