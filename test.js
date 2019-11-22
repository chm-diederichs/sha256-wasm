const sha256 = require('./')

const buf = Buffer.alloc(64)
buf.set(Buffer.from('abc'))

sha256.ready(function () {
  const hash = sha256()
  hash.digest(buf)

  console.log(hash)
})
