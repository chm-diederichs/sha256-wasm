const sha256 = require('./')
const crypto = require('crypto')
const js256 = require('js-sha256')

console.time('sha256')
for (let i = 0; i < 1000; i++) {
  const hash = sha256()
    .update('abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq')
    .update('ijkijkljklmklmnlmnomnopnopq')
    .update('ijkijkljklmklmnlmnomnopnopq')
    .update("now let's see if you can handle an exceptionally e, hopefully one that fills the block size and then some... now wouldn't that be an interesting test case, i'm sure i'd like to know the result of that. Wouldn't you?")
    .update('ijkijkljklmklmnlmnomnopnopq')
    // .update('hello')
    // .update(' world.')
    // .update(' world.')

    // .update(' whdgshjggscorld.')

    .digest('hex')
}
console.timeEnd('sha256')

console.time('js')
for (let i = 0; i < 1000; i++) {
  const hash = js256.create()
    .update('abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq')
    .update('ijkijkljklmklmnlmnomnopnopq')
    .update('ijkijkljklmklmnlmnomnopnopq')
    .update("now let's see if you can handle an exceptionally e, hopefully one that fills the block size and then some... now wouldn't that be an interesting test case, i'm sure i'd like to know the result of that. Wouldn't you?")
    .update('ijkijkljklmklmnlmnomnopnopq')
    // .update('hello')
    // .update(' world.')
    // .update(' world.')

    // .update(' whdgshjggscorld.')

    .digest('hex')
}
console.timeEnd('js')
// console.log('1', hash.slice(0, 8))
// console.log('2', hash.slice(8, 16))
// console.log('3', hash.slice(16, 24))
// console.log('4', hash.slice(24, 32))
// console.log('5', hash.slice(32, 40))
// console.log('6', hash.slice(40, 48))
// console.log('7', hash.slice(48, 56))
// console.log('8', hash.slice(56, 64))

console.time('sha256 ref')
for (let i = 0; i < 1000; i++) {
  const refHash = crypto.createHash('sha256')
    .update('abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq')
    .update('ijkijkljklmklmnlmnomnopnopq')
    .update('ijkijkljklmklmnlmnomnopnopq')
    .update("now let's see if you can handle an exceptionally e, hopefully one that fills the block size and then some... now wouldn't that be an interesting test case, i'm sure i'd like to know the result of that. Wouldn't you?")
    .update('ijkijkljklmklmnlmnomnopnopq')
    // .update('hello')

    // .update(' world.')
    // .update(' world.')
    // .update(' whdgshjggscorld.')

    .digest('hex')
}
console.timeEnd('sha256 ref')
