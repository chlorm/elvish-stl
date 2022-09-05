use ./list
use ./test


test:assert {
    var l = [ a b c ]
    var expected = [ c b a ]
    eq (list:reverse $l) $expected
}
