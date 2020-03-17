# Copyright (c) 2020, Cody Opel <cwopel@chlorm.net>
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


fn drop [list elem]{
  local:new-list = [ ]
  for local:i $list {
    if (!=s $elem $i) {
      new-list = [ $@new-list $i ]
    }
  }
  put $new-list
}

fn reverse [list]{
  local:new-list = [ ]
  for local:i $list {
    new-list = [ $i $@new-list ]
  }
  put $new-list
}
