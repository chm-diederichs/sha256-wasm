const sha256 = require('./')
const test = require('tape')

require('sha-test').sha256(sha256)

test('pass error argument if ready callback fail', t => {
  const wasm = require('./sha256.js')({
    imports: null // importing null will generate an error
  })

  wasm.onload(err => {
    t.ok(err)
    t.end()
  })
})
