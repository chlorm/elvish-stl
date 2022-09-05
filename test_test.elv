use ./test


test:pass { nop }
test:fail { fail test }
test:assert { put $true }
test:fail { test:assert { put $false } }
test:refute { put $false }
test:fail { test:refute { put $true } }
