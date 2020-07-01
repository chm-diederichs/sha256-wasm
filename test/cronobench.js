const cronometro = require('cronometro')
const { createHash, randomBytes } = require('crypto')
const sha256 = require('../')
const wasm = require('../sha256')()
const shortData = randomBytes(64)
const mediumData = randomBytes(384)
const longData = randomBytes(4096)
const megaData = randomBytes(2 ** 23)
const output256 = Buffer.alloc(32)

function size (name, data) {
  return cronometro({
    'crypto wasm sha256 (no prealloc)': function () {
      sha256().update(data).digest()
    },
    'crypt wasm sha256 (prealloc)': function () {
      sha256().update(data).digest(output256)
    },
    'crypto sha256 (no prealloc)': function () {
      createHash('sha256').update(data).digest()
    },
    'crypto sha256 (prealloc)': function () {
      createHash('sha256').update(data).digest(output256)
    }
    // 'crypto sha512 (no prealloc, digest)': function () {
    //   createHash('sha512').update(data).digest('hex')
    // }
  }, {
    iterations: 10000,
    print: {
      compare: true,
      compareMode: 'base'
    }
  })
}

;(async () => {
  await size('64 bytes', shortData)
  await size('384 bytes', mediumData)
  await size('4096 bytes', longData)
  await size('4 MB', megaData)
})()
