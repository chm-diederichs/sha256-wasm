const monolith = require('./')
const crypto = require('crypto')
const ref = require('js-sha256')
const sodium = require('sodium-native')

// timing benchmark
{
  const buf = Buffer.alloc(8192)
  sodium.randombytes_buf(buf)

  const monoHash = monolith()
  const jsHash = ref.create()
  const refHash = crypto.createHash('sha256') 
  
  console.time('monolith')
  for (let i = 0; i < 1000; i++) {
    monoHash.update(buf)
  }
  const monoRes = monoHash.digest('hex')
  console.timeEnd('monolith')

  console.time('js')
  for (let i = 0; i < 1000; i++) {
    jsHash.update(buf)
  }
  const jsRes = jsHash.hex()
  console.timeEnd('js')

  console.time('native')
  for (let i = 0; i < 1000; i++) {
    refHash.update(buf)
  }
  const refRes = refHash.digest('hex')
  console.timeEnd('native')

  console.log('\nhashes are consistent: ', monoRes === refRes && monoRes === jsRes)
}

// naive input fuzz
const bugs = []

for (let i = 0; i < 100; i++) {
  const length = Math.floor(2 ** 18 * Math.random())
  const buf = Buffer.alloc(length)
  sodium.randombytes_buf(buf)
  const hash = monolith().update(buf).digest('hex')
  const ref = crypto.createHash('sha256').update(buf).digest('hex')

  if (hash !== ref) bugs.push(length)
}

console.log('\nhashes inconsistent at lengths:', bugs, '\n')

// fuzz multiple updates
const monoHash = monolith()
const refHash = crypto.createHash('sha256') 

for (let i = 0; i < 100; i++) {
  const buf = Buffer.alloc(2**16 * Math.random())
  sodium.randombytes_buf(buf)
  
  monoHash.update(buf)
  refHash.update(buf)
}

console.log(monoHash.digest('hex'))
console.log(refHash.digest('hex'))
