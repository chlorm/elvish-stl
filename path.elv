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


use str
use github.com/chlorm/elvish-stl/list


local:delimiter = '/'
try {
  local:test = [ (put $delimiter*) ]
} except _ {
  delimiter = '\'
}

fn absolute [path]{
  path-abs $path
}

fn basename [path]{
  path-base $path
}

fn join [@objects]{
  put (path-clean (str:join $delimiter $objects))
}

fn dirname [path]{
  path-dir $path
}

fn scandir [dir]{
  local:p = $pwd
  try {
    cd $dir
  } except _ {
    fail 'directory does not exist: '$dir
  }
  cd $p

  # find returns an empty string for matches that have been filtered out.
  fn -non-empty [@s]{
    for local:i $s {
      if (!=s '' $i) {
        put $i
      }
    }
  }

  files = [ (-non-empty (e:find $dir -maxdepth 1 -not -type d -printf '%P\n')) ]
  dirs = [ (-non-empty (e:find $dir -maxdepth 1 -type d -printf '%P\n')) ]

  put [
    &root=$dir
    &dirs=$dirs
    &files=$files
  ]
}

# NOTE: this is not performant
fn walk [dir]{
  local:dir-search = [ $dir ]
  while (> (count $dir-search) 0) {
    for local:s $dir-search {
      # Update index
      dir-search = (list:drop $dir-search $s)

      local:o = (scandir $s)
      local:root = (path-clean $o[root])

      put [
        &root=$root
        &dirs=$o[dirs]
        &files=$o[files]
      ]

      # Append new directories to index
      for local:f $o[dirs] {
        dir-search = [ $@dir-search (join $root $f) ]
      }
    }
  }
}
