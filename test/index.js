const sha256 = require('../')
const crypto = require('crypto')
const tape = require('tape')
const ref = require('js-sha256')
const vectors = require('./vectors.json')

tape('empty input', function (t) {
  const hash = sha256().digest('hex')
  const ref = crypto.createHash('sha256').digest('hex')
  t.equal(hash, ref, 'consistent for empty input')
  t.end()
})

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

tape('naive input fuzz', function (t) {
  for (let i = 0; i < 10; i++) {
    const buf = crypto.randomBytes(2 ** 18 * Math.random())

    const hash = sha256().update(buf).digest('hex')
    const ref = crypto.createHash('sha256').update(buf).digest('hex')

    t.ok(hash === ref)
  }
  t.end()
})

tape('test power of 2 length buffers', function (t) {
  for (let i = 0; i < 31; i++) {
    const hash = sha256()
    const refHash = crypto.createHash('sha256')

    const buf = Buffer.alloc(2 ** i)

    const test = hash.update(buf).digest('hex')
    const ref = refHash.update(buf).digest('hex')

    t.ok(test === ref)
  }
  t.end()
})

tape('fuzz multiple updates', function (t) {
  const hash = sha256()
  const refHash = crypto.createHash('sha256')

  for (let i = 0; i < 100; i++) {
    const buf = crypto.randomBytes(2 ** 16 * Math.random())

    hash.update(buf)
    refHash.update(buf)
  }

  same(t, hash.digest(), refHash.digest(), 'multiple updates consistent')
  t.end()
})

tape('crypto-browserify test vectors', function (t) {
  let i = 1
  for (const vector of vectors) {
    const buf = Buffer.from(vector.input, 'base64')
    const hash = sha256().update(buf).digest('hex')
    t.equal(hash, vector.hash, `input ${i}`)
    i++
  }
  t.end()
})

tape('several instances updated simultaneously', function (t) {
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

  t.equal(res, res1, 'consistent with reference')
  t.equal(res1, res2, 'consistent with eachother')
  t.end()
})

tape('reported bugs', function (t) {
  const testBuf = Buffer.from('hello')

  const res = crypto.createHash('sha256').update(testBuf).digest('hex')
  const res1 = sha256().update(testBuf).digest('hex')
  const res2 = sha256().update(testBuf).digest('hex')

  t.equal(res, res1)
  t.equal(res1, res2)
  t.end()
})

tape('base64 test', function (t) {
  const testBuf = crypto.randomBytes(1024)
  const testB64 = testBuf.toString('base64')

  const b64res = crypto.createHash('sha256').update(testBuf).digest()
  const b64test = sha256().update(testB64, 'base64').digest()
  same(t, b64res, b64test, 'base64 input encoding works')

  const res = crypto.createHash('sha256').update(testBuf).digest('base64')
  const test = sha256().update(testBuf).digest('base64')
  same(t, res, test, 'base64 output encoding works')

  t.end()
})

function same (t, a, b, msg) {
  if (!msg) msg = 'contents are equal'
  for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return t.fail()
  t.pass(msg)
}
