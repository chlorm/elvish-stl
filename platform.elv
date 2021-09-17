# Copyright (c) 2021, Cody Opel <cwopel@chlorm.net>
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


use platform
use str
use github.com/chlorm/elvish-stl/wrap


var arch = $platform:arch
var os = $platform:os

var is-arm = (==s $arch 'arm')
var is-aarch64 = (==s $arch 'arm64')
var is-i686 = (==s $arch '386')
var is-x86_64 = (==s $arch 'amd64')

var is-arm = (or $is-arm $is-aarch64)
var is-x86 = (or $is-i686 $is-x86_64)

#var is-64bit

var is-darwin = (==s $os 'darwin')
var is-freebsd = (==s $os 'freebsd')
var is-linux = (==s $os 'linux')
var is-netbsd = (==s $os 'netbsd')
var is-openbsd = (==s $os 'openbsd')
var is-windows = (==s $os 'windows')

var is-bsd = (or $is-freebsd $is-netbsd $is-openbsd)
var is-unix = (not $is-windows)

var namesFormatted = [
    &arch='Arch'
    &centos='CentOS'
    &debian='Debian'
    &darwin='macOS'
    &fedora='Fedora'
    &freebsd='FreeBSD'
    &gentoo='Gentoo'
    &netbsd='NetBSD'
    &nixos='NixOS'
    &openbsd='OpenBSD'
    &opensuse='openSUSE'
    &'red hat'='Red Hat'
    &slackware='Slackware'
    &suse='SUSE'
    &triton='Triton'
    &ubuntu='Ubuntu'
    &windows='Windows'
]

fn hostname {
    platform:hostname
}

fn -name-linux {
    var distroStrings = [ ]
    for i [ (put $E:ROOT'/etc/'*'-release') ] {
        set distroStrings = [ $@distroStrings $i ]
    }
    try {
        set distroStrings = [
            $@distroStrings
            (wrap:cmd-out 'lsb_release' '-a')
        ]
    } except _ { }
    try {
        set distroStrings = [
            $@distroStrings
            (wrap:cmd-out 'uname' '-a')
        ]
    } except _ { }

    var distros = [
        'arch'
        'centos'
        'debian'
        'fedora'
        'gentoo'
        'nixos'
        'opensuse'
        'red hat'
        'slackware'
        'suse'
        'triton'
        'ubuntu'
    ]
    for distro $distros {
        for distroString $distroStrings {
            if (str:contains (str:to-lower $distroString) $distro) {
                put $distro
                return
            }
        }
    }
}

fn name {
    if $is-linux {
        var n = (-name-linux)
        put $namesFormatted[$n]
    } else {
        put $namesFormatted[$os]
    }
}

fn release {
    # FIXME:
}
