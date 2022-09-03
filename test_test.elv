use github.com/chlorm/elvish-stl/test


test:assert { nop }
test:refute { fail test }
test:assert-bool { put $true }
test:refute-bool { put $false }
