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
// assetrt head % 8 === 0 to guarantee alignment
const freeList = []

module.exports = Sha256
const hashLength = 32

function Sha256 () {
  if (!(this instanceof Sha256)) return new Sha256()
  if (!(wasm && wasm.exports)) throw new Error('WASM not loaded. Wait for Blake2b.ready(cb)')

  if (!freeList.length) {
    freeList.push(head)
    head += 512
  }

  this.finalized = false
  this.digestLength = hashLength
  this.pointer = freeList.pop()
  this.leftover

  wasm.memory.fill(0, this.pointer, this.pointer + 512)

  if (this.pointer + hashLength > wasm.memory.length) wasm.realloc(this.pointer + 512)
  
  // wasm.exports.sha256_init(0 , this.digestLength) //(this.pointer, this.digestLength)
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
  const leftover = wasm.exports.sha256_monolith(this.pointer, head, head + length + overlap, 0)

  this.leftover = wasm.memory.slice(head, head + leftover)
  return this
}

Sha256.prototype.digest = function (enc, offset = 0) {
  assert(this.finalized === false, 'Hash instance finalized')

  this.finalized = true
  freeList.push(this.pointer)

  wasm.exports.sha256_monolith(this.pointer, head, head + this.leftover.byteLength, 1)

  const resultBuf = int32reverse(wasm.memory, this.pointer, this.digestLength)

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
  const inputBuf = Buffer.from(input, enc)
  const result = new Uint8Array(inputBuf)

  return [result, result.byteLength]
}

function int32reverse (buf, start, len) {
  const result = new Uint8Array(len)

  for (let i = 0; i < len; i++) {
    const index = Math.floor(i / 4) * 4 + 3 - i % 4
    result[index] = buf[i + start]
  }

  return Buffer.from(result)
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
