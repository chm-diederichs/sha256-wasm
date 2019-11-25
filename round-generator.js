const fs = require('fs')

const str = fs.createWriteStream('output.txt')

// for (let i = 0; i < 8; i++) {
//   console.log(`i32.store offset=${4*i} (get_local $ptr) (i32.add (get_local $r${i}) (i32.load offset=${i} (get_local `)
// }

// `(i32.add (i32.add (i32.add (call $sig1 (get_local $w${i-2})) (get_local $w${i-7})) (call $sig0 (get_local $w${i-15}))) (get_local $w${i-16}))`
// `(i32.xor (get_local $w${i - 3}) (get_local $w${i - 8})`
// `(i32.xor (get_local $w${i - 14}) (get_local $w${i - 16})`

function round (i) {
  return `;; ROUND ${i}

;; precompute intermediate values

;; T1 = h + big_sig1(e) + ch(e, f, g) + K${i} + W${i}
;; T2 = big_sig0(a) + Maj(a, b, c)

(set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
(set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
(set_local $big_sig0_res (call $big_sig0 (get_local $a)))
(set_local $big_sig1_res (call $big_sig1 (get_local $e)))

(set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w${i})) (i32.load offset=${i * 4} (i32.const 32))))
(set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

;; update registers

;; h <- g
(set_local $h (get_local $g))

;; g <- f
(set_local $g (get_local $f))  

;; f <- e
(set_local $f (get_local $e))  

;; e <- d + T1
(set_local $e (i32.add (get_local $d) (get_local $T1)))

;; d <- c
(set_local $d (get_local $c))  

;; c <- b
(set_local $c (get_local $b))  

;; b <- a
(set_local $b (get_local $a))  

;; a <- T1 + T2
(set_local $a (i32.add (get_local $T1) (get_local $T2)))

`
}

const K_words = [
  '428a2f98',
  '71374491',
  'b5c0fbcf',
  'e9b5dba5',
  '3956c25b',
  '59f111f1',
  '923f82a4',
  'ab1c5ed5',
  'd807aa98',
  '12835b01',
  '243185be',
  '550c7dc3',
  '72be5d74',
  '80deb1fe',
  '9bdc06a7',
  'c19bf174',
  'e49b69c1',
  'efbe4786',
  '0fc19dc6',
  '240ca1cc',
  '2de92c6f',
  '4a7484aa',
  '5cb0a9dc',
  '76f988da',
  '983e5152',
  'a831c66d',
  'b00327c8',
  'bf597fc7',
  'c6e00bf3',
  'd5a79147',
  '06ca6351',
  '14292967',
  '27b70a85',
  '2e1b2138',
  '4d2c6dfc',
  '53380d13',
  '650a7354',
  '766a0abb',
  '81c2c92e',
  '92722c85',
  'a2bfe8a1',
  'a81a664b',
  'c24b8b70',
  'c76c51a3',
  'd192e819',
  'd6990624',
  'f40e3585',
  '106aa070',
  '19a4c116',
  '1e376c08',
  '2748774c',
  '34b0bcb5',
  '391c0cb3',
  '4ed8aa4a',
  '5b9cca4f',
  '682e6ff3',
  '748f82ee',
  '78a5636f',
  '84c87814',
  '8cc70208',
  '90befffa',
  'a4506ceb',
  'bef9a3f7',
  'c67178f2'
]

const IV = [
  '6a09e667',
  'bb67ae85',
  '3c6ef372',
  'a54ff53a',
  '510e527f',
  '9b05688c',
  '1f83d9ab',
  '5be0cd19'
]

for (let i = 0; i < 64; i++) {
  str.write(round(i))
  // console.log(`i32.store (i32.const ${292 + 4 * i}) (get_local $w${i}))`)
}

// for (let word of IV) {
//   console.log(reverseEndian(word))
// }

function reverseEndian (string) {
  const reverse = []
  for (let i = 0; i < string.length / 2; i++) {
    reverse.push(string.slice(string.length - (2 * (i + 1)), string.length - (2 * i)))
  }

  return reverse.join('')
}
