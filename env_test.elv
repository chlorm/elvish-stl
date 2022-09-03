use github.com/chlorm/elvish-stl/env
use github.com/chlorm/elvish-stl/test


test:assert {
    env:set TESTVAR1234 '/path1:/path2'
    env:append TESTVAR1234 '/path3'
    ==s (env:get TESTVAR1234) '/path1:/path2:/path3'
}

# Invalid delimiter
test:fail {
    env:set TESTVAR1234 '/path1:/path2'
    env:append TESTVAR1234 '/path3' &delimiter=''
}

test:assert {
    env:set TESTVAR1234 '/path1:/path2'
    env:prepend TESTVAR1234 '/path3'
    ==s (env:get TESTVAR1234) '/path3:/path1:/path2'
}
