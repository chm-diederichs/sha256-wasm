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
  this.digestLength = 32
  this.leftover = 0
  this.pointer = freeList.pop()
  this.result

  wasm.memory.fill(0, this.pointer, this.pointer + 512)

  if (this.pointer + hashLength > wasm.memory.length) wasm.realloc(this.pointer + 512)
  
  // wasm.exports.sha256_init(0 , this.digestLength) //(this.pointer, this.digestLength)
}

Sha256.prototype.update = function (input) {
  // assert input % 8 === 0 for alignment

  let [ inputBuf, length ] = formatInput(input)
  assert(this.finalized === false, 'Hash instance finalized')
  assert(inputBuf instanceof Uint8Array, 'input must be Uint8Array or Buffer')
  if (head + input.length > wasm.memory.length) wasm.realloc(head + input.length)

  wasm.memory.set(inputBuf, this.leftover + head)

  this.leftover = wasm.exports.sha256_monolith(this.pointer, head, head + length + this.leftover, 0)
  return this
}

Sha256.prototype.digest = function (enc) {
  // console.log(wasm.memory.subarray(288, 388), 'input data')
  assert(this.finalized === false, 'Hash instance finalized')
  this.finalized = true
  // console.log(hexSlice(wasm.memory, 1400, 128))
  freeList.push(this.pointer)
  wasm.exports.sha256_monolith(this.pointer, head, head + this.leftover, 1)
  // console.log(hexSlice(wasm.memory, 704, 128))
  // console.log(hexSlice(wasm.memory, 1400, 128))
  // console.log(wasm.memory.subarray(this.pointer, this.pointer + 32), head, this.pointer)


  // if (!enc || end === 'binary') {    
  //   return wasm.memory.slice(this.pointer, this.pointer + 32)
  // }

  this.result = int32reverse(wasm.memory, this.pointer, this.digestLength)
  return this.result
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

function formatInput (input) {
  const value = new Uint8Array(Buffer.from(input))
  return [value, value.byteLength]

  if (input instanceof Uint8Array) return input

  const inputArray = new Uint32Array(Math.ceil(input.length / 4))

  const buf = Buffer.alloc(inputArray.byteLength)
  buf.set(Buffer.from(input, 'utf8'), 0)

  let i = 0

  for (; i < buf.byteLength / 4; i++) {
    inputArray[i] = buf.readUInt32LE(4 * i)
  }

  return [
    new Uint8Array(inputArray.buffer),
    input.length
  ]
}

function int32reverse (buf, start, len) {
  var str = ''
  var chars = []

  for (let i = 0; i < len; i++) {
    chars.push(toHex(buf[start + i]))

    if ((i + 1) % 4 === 0) {
      str += chars.reverse().join('')
      chars = []
    }
  }

  return str
}

function hexSlice (buf, start, len) {
  var str = ''
  for (var i = 0; i < len; i++) str += toHex(buf[start + i])
  return str
}

function toHex (n) {
  if (n < 16) return '0' + n.toString(16)
  return n.toString(16)
}
