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


use github.com/chlorm/elvish-stl/io
use github.com/chlorm/elvish-stl/re
use github.com/chlorm/elvish-stl/str


# Converts an ini file into a map.
fn read {|file|
    var i = (io:open $file)
    var sectionNameRegex = "(\\[.*\\])"$str:LINE-DELIMITER
    var sectionKvsRegex = "((?:[a-zA-Z0-9.=-]+"$str:LINE-DELIMITER")+)"
    var sections = [(
        re:finds $sectionNameRegex$sectionKvsRegex $i
    )]

    var o = [&]
    for section $sections {
        var sectionName = (re:find '\[(.*)\]' $section[0])
        set o[$sectionName] = [&]
        for kv [ (str:split $str:LINE-DELIMITER $section[1]) ] {
            if (==s $kv '') {
                continue
            }
            set kv = [ (str:split '=' $kv) ]
            set o[$sectionName][$kv[0]] = $kv[1]
        }
    }
    put $o
}
