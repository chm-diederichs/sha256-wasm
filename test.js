const sha256 = require('./')

const buf = new Uint8Array(64)
buf[0] = 0x61
buf[1] = 0x62
buf[2] = 0x63
buf[3] = 0x80

sha256.ready(function () {
  const hash = sha256()
    .update(buf)
    .digest('hex')

  console.log('hash', hash)
})
