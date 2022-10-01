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


use str
use ./platform
use ./re


var LINE-DELIMITER = "\n"
if $platform:is-windows {
    set LINE-DELIMITER = "\r\n"
}

fn has {|searchIn searchFor|
    str:contains $searchIn $searchFor
}

fn is-empty {|string|
    re:has '^([\s]+)?$' $string
}

fn has-prefix {|string prefix|
    str:has-prefix $string $prefix
}

fn has-suffix {|string suffix|
    str:has-suffix $string $suffix
}

fn join {|delimitByString listOfStrings|
    str:join $delimitByString $listOfStrings
}

fn replace {|stringToMatch stringToSubstitute string|
    str:replace $stringToMatch $stringToSubstitute $string
}

fn split {|splitOnString string|
    str:split $splitOnString $string
}

fn to-lines {|fileStr &line-delimiter=$nil|
    if (eq $line-delimiter $nil) {
        set line-delimiter = $LINE-DELIMITER
    }

    for s [ (split $line-delimiter $fileStr) ] {
        if (==s $s '') {
            continue
        }
        put $s
    }
}

fn to-lower {|string|
    str:to-lower $string
}

fn to-upper {|string|
    str:to-upper $string
}
