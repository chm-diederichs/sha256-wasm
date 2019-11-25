const sha256 = require('./')

const buf = new Uint8Array(64)
buf[0] = 0x80
buf[1] = 0x63
buf[2] = 0x62
buf[3] = 0x61
buf[60] = 0x18

const hash = sha256()
  .update(buf)
  .digest('hex')
console.log(hash)
// console.log('1', hash.slice(0, 8))
// console.log('2', hash.slice(8, 16))
// console.log('3', hash.slice(16, 24))
// console.log('4', hash.slice(24, 32))
// console.log('5', hash.slice(32, 40))
// console.log('6', hash.slice(40, 48))
// console.log('7', hash.slice(48, 56))
// console.log('8', hash.slice(56, 64))
