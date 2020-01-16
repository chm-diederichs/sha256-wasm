const sha256 = require('./')
const crypto = require('crypto')
const ref = require('js-sha256')
const vectors = require('./vectors.json')

// timing benchmark
{
  const buf = Buffer.alloc(8192)
  crypto.randomFillSync(buf)

  const hash = sha256()
  const jsHash = ref.create()
  const refHash = crypto.createHash('sha256') 

  console.time('wasm')
  for (let i = 0; i < 1000; i++) {
    hash.update(buf)
  }
  const res = hash.digest('hex')
  console.timeEnd('wasm')

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

  console.log('\nhashes are consistent: ', res === refRes && res === jsRes)
}

{
  // naive input fuzz
  const bugs = []

  for (let i = 0; i < 10; i++) {
    const buf = crypto.randomBytes(2 ** 18 * Math.random())

    const hash = sha256().update(buf).digest('hex')
    const ref = crypto.createHash('sha256').update(buf).digest('hex')

    if (hash !== ref) bugs.push(length)
  }

  console.log('\nhashes inconsistent at lengths:', bugs)
}

// test power of 2 length buffers
{
  const failed = []

  for (let i = 0; i < 31; i++) {  
    const hash = sha256()
    const refHash = crypto.createHash('sha256')
    
    const buf = Buffer.alloc(2 ** i)

    const test = hash.update(buf).digest('hex')
    const ref = refHash.update(buf).digest('hex')

    if (test !== ref) failed.push(2 ** i)
  }

  console.log('\nthese lengths failed: ', failed, '\n')
}

// fuzz multiple updates
{
  const hash = sha256()
  const refHash = crypto.createHash('sha256')

  for (let i = 0; i < 100; i++) {  
    const buf = crypto.randomBytes(2**16 * Math.random())

    hash.update(buf)
    refHash.update(buf)
  }

  console.log(hash.digest('hex'))
  console.log(refHash.digest('hex'))
}

// crypto-browserify test vectors
{
  const failed  = []

  for (let vector of vectors) {
    const buf = Buffer.from(vector.input, 'base64')
    const hash = sha256().update(buf).digest('hex')
    if (hash !== vector.hash) failed.push(vector)
  }

  console.log('\nthese test vectors failed: ', failed)
}

// several instances updated simultaneously
{
  const hash1 = sha256() 
  const hash2 = sha256()
  const refHash = crypto.createHash('sha256')

  const buf = Buffer.alloc(1024)

  for (let i = 0; i < 10; i++) {
    crypto.randomFillSync(buf)

    if (Math.random() < 0.5) {
      hash1.update(buf)
      hash2.update(buf)
    } else {
      hash2.update(buf)
      hash1.update(buf)
    }
    refHash.update(buf)
  }

  const res = refHash.digest('hex')
  const res1 = hash1.digest('hex')
  const res2 = hash2.digest('hex')

  console.log('\nhashes invariant to update order: ', res === res1 && res1 === res2)
}

// reported bugs
{
  const testBuf = Buffer.from('hello')

  const res = crypto.createHash('sha256').update(testBuf).digest('hex')
  const res1 = sha256().update(testBuf).digest('hex')
  const res2 = sha256().update(testBuf).digest('hex')
    
  console.log('\nreported bugs no longer throw: ', res1 === res2 && res1 == res)
}
