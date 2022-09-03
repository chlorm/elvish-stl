use github.com/chlorm/elvish-stl/list
use github.com/chlorm/elvish-stl/test


test:assert-bool {
    var l = [ a b c ]
    var expected = [ c b a ]
    eq (list:reverse $l) $expected
}
