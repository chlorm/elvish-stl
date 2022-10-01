use ./str
use ./test

test:assert { str:is-empty '          ' }
test:fail { str:is-empty $nil }
test:assert { str:is-empty '' }
test:refute { str:is-empty 'abc' }

test:assert { eq [ (str:to-lines "a\n\nb") ] [ a '' b ] }

test:assert { eq [ (str:to-nonempty-lines "a\n\nb") ] [ a b ] }
