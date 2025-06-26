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


use ./map
use ./re
use ./str


# Parses ini encoded data and returns a map.
fn unmarshal {|fileStr &line-delimiter=$nil|
    if (eq $line-delimiter $nil) {
        set line-delimiter = $str:LINE-DELIMITER
    }

    var printable = '\p{L}\p{M}\p{N}\p{P}\p{S}\p{Z}'
    var sectionNameRegex = '\[(['$printable']+)\]'$line-delimiter
    var sectionKvsRegex = '?((?:['$printable']+'$line-delimiter')+)'
    var sections = [(
        re:finds $sectionNameRegex$sectionKvsRegex $fileStr
    )]

    var o = [&]
    for section $sections {
        var sectionName = $section[0]
        set o[$sectionName] = [&]
        for kv [ (str:split $line-delimiter $section[1]) ] {
            if (or (==s $kv '') (re:match '^([\s]+|)#' $kv)) {
                continue
            }
            set kv = [ (str:split '=' $kv) ]
            set o[$sectionName][$kv[0]] = $kv[1]
        }
    }
    put $o
}

# Returns ini encoding of a map.
fn marshal {|map &line-delimiter=$nil &pad-equals=$false|
    if (eq $line-delimiter $nil) {
        set line-delimiter = $str:LINE-DELIMITER
    }

    var equals = "="
    if $pad-equals {
        set equals = " = "
    }

    var o = ""
    for section [ (map:keys $map) ] {
        set o = $o"["$section"]"$line-delimiter
        for key [ (map:keys $map[$section]) ] {
            set o = $o$key$equals$map[$section][$key]$line-delimiter
        }
        set o = $o$line-delimiter
    }
    put $o
}
