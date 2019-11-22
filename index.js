const assert = require('nanoassert')
const wasm = require('./sha256')()

let head = 288
const freeList = []

module.exports = Sha256

const hashLength = 32
const wordConstantsLength = 256


function Sha256 () {
  if (!(this instanceof Sha256)) return new Sha256()
  if (!(wasm && wasm.exports)) throw new Error('WASM not loaded. Wait for Blake2b.ready(cb)')

  if (!freeList.length) {
    freeList.push(head)
    head += 348
  }

  this.finalized = false
  this.digestLength = 32
  this.pointer = freeList.pop()

  wasm.memory.fill(0, 0, hashLength + wordConstantsLength)

  if (this.pointer + hashLength + wordConstantsLength > wasm.memory.length) wasm.realloc(this.pointer + 312)
  wasm.exports.sha256_init(0, this.digestLength)
  console.log(hexSlice(wasm.memory, 32, 256))
  
}

Sha256.prototype.update = function (input) {
  assert(this.finalized === false, 'Hash instance finalized')
  assert(input instanceof Uint8Array, 'input must be Uint8Array or Buffer')
  console.log('hello')

  if (head + input.length > wasm.memory.length) wasm.realloc(head + input.length)
  wasm.memory.set(input, head)
  console.log(wasm.memory.subarray(head), head)
  wasm.exports.sha256_update(this.pointer, head, head + 64)
  return this
}

Sha256.prototype.digest = function (enc) {
  console.log(wasm.memory.subarray(32, 288), 'wooooord')
  assert(this.finalized === false, 'Hash instance finalized')
  this.finalized = true

  freeList.push(this.pointer)
  wasm.exports.sha256_compress(this.pointer)
  console.log(wasm.memory.subarray(this.pointer, this.pointer + 32), head, this.pointer)

  // if (!enc || end === 'binary') {    
  //   return wasm.memory.slice(this.pointer, this.pointer + 32)
  // }


  console.log(this.pointer)
  if (enc === 'hex') {
    return hexSlice(wasm.memory, this.pointer, 32)
  }

  assert(enc instanceof Uint8Array && enc.length >= 32, 'input must be Uint8Array or Buffer')
  for (let i = 0; i < 32; i++) {
    enc[i] = wasm.memory[this.pointer + 32 + i]
  }

  return enc
}

Sha256.ready = function (cb) {
  if (!cb) cb = noop
  if (!wasm) return cb(new Error('WebAssembly not supported'))

  var p = new Promise(function (reject, result) {
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

function hexSlice (buf, start, len) {
  var str = ''
  for (var i = 0; i < len; i++) str += toHex(buf[start + i])
  console.log(str)
  return str
}

function toHex (n) {
  if (n < 16) return '0' + n.toString(16)
  return n.toString(16)
}
