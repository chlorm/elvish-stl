use ./env
use ./test


test:assert {
    set-env TEST_HAS_ELEM1 'a:b:c'
    env:has-elem &delimiter=':' TEST_HAS_ELEM1 'b'
}
test:refute {
    set-env TEST_HAS_ELEM2 'a:b:c'
    env:has-elem &delimiter=$nil TEST_HAS_ELEM2 'non-existant'
}
test:refute {
    set-env TEST_HAS_ELEM3 'a:b:c'
    env:has-elem &delimiter='' TEST_HAS_ELEM3 'non-existant'
}

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
