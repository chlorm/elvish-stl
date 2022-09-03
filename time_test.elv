use github.com/chlorm/elvish-stl/re
use github.com/chlorm/elvish-stl/test
use github.com/chlorm/elvish-stl/time


test:assert-bool { re:match "^[0-9]{8}$" (time:date) }
