# Copyright (c) 2020, 2022, Cody Opel <cwopel@chlorm.net>
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


use re


# Returns the match string from an re:find object
fn -find-obj {|reFindObject|
    put $reFindObject['groups'][1..][0]['text']
}

fn -find-objs {|reFindObject|
    var l = [ ]
    for i $reFindObject['groups'][1..] {
        set l = [ $@l $i['text'] ]
    }
    put $l
}

# Returns a string instead of an object like re:find
fn find {|regex string|
    re:find $regex $string | peach {|i|
        -find-obj $i
    }
}

# Returns a list of strings corresponding to each match group.
fn finds {|regex string|
    re:find $regex $string | peach {|i|
        -find-objs $i
    }
}


fn match {|pattern string|
    re:match $pattern $string
}

fn replace {|regex substituteString string|
    re:replace $regex $substituteString $string
}
