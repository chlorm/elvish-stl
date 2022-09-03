use github.com/chlorm/elvish-stl/list
use github.com/chlorm/elvish-stl/test


test:assert {
    var l = [ a b c ]
    var expected = [ c b a ]
    eq (list:reverse $l) $expected
}
