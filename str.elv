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


fn has {|searchIn searchFor|
    str:contains $searchIn $searchFor
}

fn has-suffix {||}

fn join {|joinWithStr listOfStrs|
    str:join $joinWithStr $listOfStrs
}

fn replace {|strToMatch strToSub string|
    str:replace $strToMatch strToSub $string
}

fn split {|splitOnStr listOfStrs|
    str:split $splitOnStr $listOfStrs
}

fn to-lower {|string|
    str:to-lower $string
}

fn to-upper {|string|
    str:to-upper $string
}