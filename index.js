const assert = require('nanoassert')
const wasm = require('./sha256.js')({
  imports: {
    debug: {
      log (...args) {
        console.log(...args.map(int => (int >>> 0).toString(16).padStart(8, '0')))
      },
      log_tee (arg) {
        console.log((arg >>> 0).toString(16).padStart(8, '0'))
        return arg
      }
    }
  }
})

let head = 0
const freeList = []

module.exports = Sha256
const SHA256_BYTES = module.exports.SHA256_BYTES = 32
const SHA256_STATE = 100

function Sha256 () {
  if (!(this instanceof Sha256)) return new Sha256()
  if (!(wasm && wasm.exports)) throw new Error('WASM not loaded. Wait for Sha256.ready(cb)')

  if (!freeList.length) {
    freeList.push(head)
    head += 100 // need 100 bytes for internal state
  }

  this.finalized = false
  this.digestLength = SHA256_BYTES
  this.pointer = freeList.pop()
  this.leftover = Buffer.alloc(0)

  wasm.memory.fill(0, this.pointer, this.pointer + 100)

  if (this.pointer + this.digestLength > wasm.memory.length) wasm.realloc(this.pointer + 100)
}

Sha256.prototype.update = function (input, enc) {
  assert(this.finalized === false, 'Hash instance finalized')

  if (head % 4 !== 0) head += 4 - head % 4
  assert(head % 4 === 0, 'input shoud be aligned for int32')

  let [ inputBuf, length ] = formatInput(input, enc)
  
  assert(inputBuf instanceof Uint8Array, 'input must be Uint8Array or Buffer')
  
  if (head + length > wasm.memory.length) wasm.realloc(head + input.length)
  
  if (this.leftover != null) {
    wasm.memory.set(this.leftover, head)
    wasm.memory.set(inputBuf, this.leftover.byteLength + head)
  } else {
    wasm.memory.set(inputBuf, head)
  }
  
  const overlap = this.leftover ? this.leftover.byteLength : 0
  const leftover = wasm.exports.sha256(this.pointer, head, head + length + overlap, 0)

  this.leftover = inputBuf.slice(inputBuf.byteLength - leftover)
  return this
}

Sha256.prototype.digest = function (enc, offset = 0) {
  assert(this.finalized === false, 'Hash instance finalized')

  this.finalized = true
  freeList.push(this.pointer)

  wasm.exports.sha256(this.pointer, head, head + this.leftover.byteLength, 1)

  const resultBuf = readReverseEndian(wasm.memory, 4, this.pointer, this.digestLength)

  if (!enc) {    
    return resultBuf
  }

  if (typeof enc === 'string') {
    return resultBuf.toString(enc)
  }

  assert(enc instanceof Uint8Array, 'input must be Uint8Array or Buffer')
  assert(enc.byteLength >= this.digestLength + offset, 'input not large enough for digest')

  for (let i = 0; i < this.digestLength; i++) {
    enc[i + offset] = resultBuf[i]
  }

  return enc
}

Sha256.ready = function (cb) {
  if (!cb) cb = noop
  if (!wasm) return cb(new Error('WebAssembly not supported'))

  var p = new Promise(function (reject, resolve) {
    wasm.onload(function (err) {
      if (err) resolve(err)
      else reject()
      cb(err)
    })
  })

  return p
}

Sha256.prototype.ready = Sha256.ready

function noop () {}

function formatInput (input, enc = null) {
  let result
  if (Buffer.isBuffer(input)) {
    result = input
  } else {
    result = Buffer.from(input, enc)
  }

  return [result, result.byteLength]
}

function readReverseEndian (buf, interval, start, len) {
  const result = Buffer.allocUnsafe(len)

  for (let i = 0; i < len; i++) {
    const index = Math.floor(i / interval) * interval + (interval - 1) - i % interval
    result[index] = buf[i + start]
  }

  return result
}

function hexSlice (buf, start = 0, len) {
  if (!len) len = buf.byteLength

  var str = ''
  for (var i = 0; i < len; i++) str += toHex(buf[start + i])
  return str
}

function toHex (n) {
  if (n < 16) return '0' + n.toString(16)
  return n.toString(16)
}
