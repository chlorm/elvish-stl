use github.com/chlorm/elvish-stl/re
use github.com/chlorm/elvish-stl/test


test:assert { ==s (re:find '.*(answer).*' 'kasjdhfanswergasdfg') 'answer' }
