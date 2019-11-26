const sha256 = require('./')

const a = 0x61

const arr = new Uint8Array(128)

let count = 0

for (let i = 0; i < 14; i++) {
  arr[count++] = a + i + 3
  arr[count++] = a + i + 2
  arr[count++] = a + i + 1
  arr[count++] = a + i
}
arr[count] = 0x80

arr[126] = 0x01
arr[127] = 0xc0


const hash = sha256()
  .update('abc')
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
