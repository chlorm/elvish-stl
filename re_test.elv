use ./re
use ./test


test:assert { ==s (re:find '.*(answer).*' 'kasjdhfanswergasdfg') 'answer' }
