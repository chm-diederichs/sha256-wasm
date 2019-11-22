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

(set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
(set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
(set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
(set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

;; T1 = h + big_sig1(e) + ch(e, f, g) + K${i} + W${i}
;; T2 = big_sig0(a) + Maj(a, b, c)

(set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w${i})) (i32.load offset=${i * 4} (i32.const 32))))
(set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

;; update registers

;; h <- g
(set_local $r7 (get_local $r6))

;; g <- f
(set_local $r6 (get_local $r5))  

;; f <- e
(set_local $r5 (get_local $r4))  

;; e <- d + T1
(set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

;; d <- c
(set_local $r3 (get_local $r2))  

;; c <- b
(set_local $r2 (get_local $r1))  

;; b <- a
(set_local $r1 (get_local $r0))  

;; a <- T1 + T2
(set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

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


for (let i = 0; i < 64; i++) {
  str.write(round(i))
}
