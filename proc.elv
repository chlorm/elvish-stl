# Copyright (c) 2022, Cody Opel <cwopel@chlorm.net>
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


use ./exec
use ./platform


fn kill {|processId|
    if $platform:is-windows {
        exec:ps 'Stop-Process' '-Id' $processId '-Confirm'
        return
    }

    exec:cmd 'kill' $processId
}

fn pidsof {|processName|
    var pids = [ ]
    if $platform:is-windows {
        set pids = [ (exec:ps-out '(Get-Process '$processName').Id') ]
    } else {
        set pids = [ (exec:cmd-out 'pidof' $processName) ]
    }
    put $pids
}
