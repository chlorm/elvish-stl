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


use github.com/chlorm/elvish-stl/map
use github.com/chlorm/elvish-stl/re
use github.com/chlorm/elvish-stl/str


# Parses ini encoded data and returns a map.
fn unmarshal {|fileStr &line-delimiter=$str:LINE-DELIMITER|
    var sectionNameRegex = "(\\[.*\\])"$line-delimiter
    var sectionKvsRegex = "((?:[a-zA-Z0-9.=-]+"$line-delimiter")+)"
    var sections = [(
        re:finds $sectionNameRegex$sectionKvsRegex $fileStr
    )]

    var o = [&]
    for section $sections {
        var sectionName = (re:find '\[(.*)\]' $section[0])
        set o[$sectionName] = [&]
        for kv [ (str:split $line-delimiter $section[1]) ] {
            if (==s $kv '') {
                continue
            }
            set kv = [ (str:split '=' $kv) ]
            set o[$sectionName][$kv[0]] = $kv[1]
        }
    }
    put $o
}

# Returns ini encoding of a map.
fn marshal {|map &line-delimiter=$str:LINE-DELIMITER|
    var o = ""
    for section [ (map:keys $map) ] {
        set o = $o"["$section"]"$line-delimiter
        for key [ (map:keys $map[$section]) ] {
            set o = $o$key"="$map[$section][$key]$line-delimiter
        }
        set o = $o$line-delimiter
    }
    put $o
}
