use ./re
use ./test
use ./time


test:assert { re:match "^[0-9]{8}$" (time:date) }
