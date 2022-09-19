use ./path
use ./test
use ./utils


test:assert {
    set-env TEST_CMDS_VAR 'non-existant-cmd,whoami,hostname'
    var cmds = [ another-non-existant-cmd ]
    var cmd = (utils:get-preferred-cmd TEST_CMDS_VAR $cmds)
    set cmd = (path:basename $cmd)
    ==s $cmd 'whoami'
}
test:assert {
    set-env TEST_CMDS_VAR 'non-existant-cmd,another-non-existant-cmd'
    var cmds = [ whoami hostname ]
    var cmd = (utils:get-preferred-cmd TEST_CMDS_VAR $cmds)
    set cmd = (path:basename $cmd)
    ==s $cmd 'whoami'
}

test:assert { utils:is-nil '' }
test:assert { utils:is-nil '          ' }
test:assert { utils:is-nil $nil }
test:refute { utils:is-nil 'asdf' }

test:pass { utils:test-writeable $pwd }
