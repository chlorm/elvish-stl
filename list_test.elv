use ./list
use ./test


test:assert { list:has [ a b c ] b }
test:refute { list:has [ a b c ] d }

test:assert { eq (list:drop [ a b c ] b) [ a c ] }

test:assert { eq (list:reverse [ a b c ]) [ c b a ] }
