(module
  (memory $0 1)
  (export "memory" (memory $0))

  (global $a (mut i32) (i32.const 0))
  (global $b (mut i32) (i32.const 0))
  (global $c (mut i32) (i32.const 0))
  (global $d (mut i32) (i32.const 0))
  (global $e (mut i32) (i32.const 0))
  (global $f (mut i32) (i32.const 0))
  (global $g (mut i32) (i32.const 0))
  (global $h (mut i32) (i32.const 0))

  (func $i32.bswap
    (param $b i32)
    (result i32)

    ;; 2 get, 4 const, 5 bitwise

    (i32.or
      (local.get $b)
      (i32.const 0x00FF00FF)
      (i32.and)
      (i32.rotr (i32.const 8))

      (local.get $b)
      (i32.const 0xFF00FF00)
      (i32.and)
      (i32.rotl (i32.const 8))))

  (func $four_round 
    (param $w0 i32) (param $w1 i32) (param $w2 i32) (param $w3 i32)
    (param $k0 i32) (param $k1 i32) (param $k2 i32) (param $k3 i32)

    ;; precomputed values
    (local $T1 i32)
    (local $T2 i32)

    (local $ch_res i32)
    (local $maj_res i32)
    (local $big_sig0_res i32)
    (local $big_sig1_res i32)

    ;; precompute intermediate values
    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K0 + W0
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    ;; can compute 4 rounds independently

    (local.set $ch_res (i32.xor (i32.and (global.get $e) (global.get $f)) (i32.and (i32.xor (global.get $e) (i32.const -1)) (global.get $g))))
    (local.set $maj_res (i32.xor (i32.xor (i32.and (global.get $a) (global.get $b)) (i32.and (global.get $a) (global.get $c))) (i32.and (global.get $b) (global.get $c))))
    (local.set $big_sig0_res (i32.xor (i32.xor (i32.rotr (global.get $a) (i32.const 2)) (i32.rotr (global.get $a) (i32.const 13))) (i32.rotr (global.get $a) (i32.const 22))))
    (local.set $big_sig1_res (i32.xor (i32.xor (i32.rotr (global.get $e) (i32.const 6)) (i32.rotr (global.get $e) (i32.const 11))) (i32.rotr (global.get $e) (i32.const 25))))
    (local.set $T1 (i32.add (i32.add (i32.add (i32.add (global.get $h) (local.get $ch_res)) (local.get $big_sig1_res)) (local.get $w0)) (local.get $k0)))
    (local.set $T2 (i32.add (local.get $big_sig0_res) (local.get $maj_res)))

    (global.set $h (i32.add (global.get $d) (local.get $T1)))
    (global.set $d (i32.add (local.get $T1) (local.get $T2)))

    (local.set $ch_res (i32.xor (i32.and (global.get $h) (global.get $e)) (i32.and (i32.xor (global.get $h) (i32.const -1)) (global.get $f))))
    (local.set $maj_res (i32.xor (i32.xor (i32.and (global.get $d) (global.get $a)) (i32.and (global.get $d) (global.get $b))) (i32.and (global.get $a) (global.get $b))))
    (local.set $big_sig0_res (i32.xor (i32.xor (i32.rotr (global.get $d) (i32.const 2)) (i32.rotr (global.get $d) (i32.const 13))) (i32.rotr (global.get $d) (i32.const 22))))
    (local.set $big_sig1_res (i32.xor (i32.xor (i32.rotr (global.get $h) (i32.const 6)) (i32.rotr (global.get $h) (i32.const 11))) (i32.rotr (global.get $h) (i32.const 25))))
    (local.set $T1 (i32.add (i32.add (i32.add (i32.add (global.get $g) (local.get $ch_res)) (local.get $big_sig1_res)) (local.get $w1)) (local.get $k1)))
    (local.set $T2 (i32.add (local.get $big_sig0_res) (local.get $maj_res)))

    (global.set $g (i32.add (global.get $c) (local.get $T1)))
    (global.set $c (i32.add (local.get $T1) (local.get $T2)))

    (local.set $ch_res (i32.xor (i32.and (global.get $g) (global.get $h)) (i32.and (i32.xor (global.get $g) (i32.const -1)) (global.get $e))))
    (local.set $maj_res (i32.xor (i32.xor (i32.and (global.get $c) (global.get $d)) (i32.and (global.get $c) (global.get $a))) (i32.and (global.get $d) (global.get $a))))
    (local.set $big_sig0_res (i32.xor (i32.xor (i32.rotr (global.get $c) (i32.const 2)) (i32.rotr (global.get $c) (i32.const 13))) (i32.rotr (global.get $c) (i32.const 22))))
    (local.set $big_sig1_res (i32.xor (i32.xor (i32.rotr (global.get $g) (i32.const 6)) (i32.rotr (global.get $g) (i32.const 11))) (i32.rotr (global.get $g) (i32.const 25))))
    (local.set $T1 (i32.add (i32.add (i32.add (i32.add (global.get $f) (local.get $ch_res)) (local.get $big_sig1_res)) (local.get $w2)) (local.get $k2)))
    (local.set $T2 (i32.add (local.get $big_sig0_res) (local.get $maj_res)))

    (global.set $f (i32.add (global.get $b) (local.get $T1)))
    (global.set $b (i32.add (local.get $T1) (local.get $T2)))

    (local.set $ch_res (i32.xor (i32.and (global.get $f) (global.get $g)) (i32.and (i32.xor (global.get $f) (i32.const -1)) (global.get $h))))
    (local.set $maj_res (i32.xor (i32.xor (i32.and (global.get $b) (global.get $c)) (i32.and (global.get $b) (global.get $d))) (i32.and (global.get $c) (global.get $d))))
    (local.set $big_sig0_res (i32.xor (i32.xor (i32.rotr (global.get $b) (i32.const 2)) (i32.rotr (global.get $b) (i32.const 13))) (i32.rotr (global.get $b) (i32.const 22))))
    (local.set $big_sig1_res (i32.xor (i32.xor (i32.rotr (global.get $f) (i32.const 6)) (i32.rotr (global.get $f) (i32.const 11))) (i32.rotr (global.get $f) (i32.const 25))))
    (local.set $T1 (i32.add (i32.add (i32.add (i32.add (global.get $e) (local.get $ch_res)) (local.get $big_sig1_res)) (local.get $w3)) (local.get $k3)))
    (local.set $T2 (i32.add (local.get $big_sig0_res) (local.get $maj_res)))

    (global.set $e (i32.add (global.get $a) (local.get $T1)))
    (global.set $a (i32.add (local.get $T1) (local.get $T2))))

  (func $expand
    (param $a i32) (param $b i32) (param $c i32) (param $d i32)
    (result i32)

    (i32.add
      (i32.add
        (i32.add
          (i32.xor
            (i32.xor
              (i32.rotr (local.get $a) (i32.const 17))
              (i32.rotr (local.get $a) (i32.const 19)))
            (i32.shr_u (local.get $a) (i32.const 10)))
          (local.get $b))
        (i32.xor
          (i32.xor
            (i32.rotr (local.get $c) (i32.const 7))
            (i32.rotr (local.get $c) (i32.const 18)))
          (i32.shr_u (local.get $c) (i32.const 3)))
        (local.get $d))))

  (func $sha256_init (export "sha256_init")
    (param $ctx i32)

    ;;  store inital state
    (i32.store offset=0  (local.get $ctx) (i32.const 0x6a09e667))
    (i32.store offset=4  (local.get $ctx) (i32.const 0xbb67ae85))
    (i32.store offset=8  (local.get $ctx) (i32.const 0x3c6ef372))
    (i32.store offset=12 (local.get $ctx) (i32.const 0xa54ff53a))
    (i32.store offset=16 (local.get $ctx) (i32.const 0x510e527f))
    (i32.store offset=20 (local.get $ctx) (i32.const 0x9b05688c))
    (i32.store offset=24 (local.get $ctx) (i32.const 0x1f83d9ab))
    (i32.store offset=28 (local.get $ctx) (i32.const 0x5be0cd19)))

  (func $compress
    (param $ctx i32)

    (param $w0 i32) (param $w1 i32) (param $w2 i32) (param $w3 i32)
    (param $w4 i32) (param $w5 i32) (param $w6 i32) (param $w7 i32)
    (param $w8 i32) (param $w9 i32) (param $w10 i32) (param $w11 i32)
    (param $w12 i32) (param $w13 i32) (param $w14 i32) (param $w15 i32)

    ;; expanded message schedule
    (local $w16 i32) (local $w17 i32) (local $w18 i32) (local $w19 i32) 
    (local $w20 i32) (local $w21 i32) (local $w22 i32) (local $w23 i32)
    (local $w24 i32) (local $w25 i32) (local $w26 i32) (local $w27 i32) 
    (local $w28 i32) (local $w29 i32) (local $w30 i32) (local $w31 i32)
    (local $w32 i32) (local $w33 i32) (local $w34 i32) (local $w35 i32) 
    (local $w36 i32) (local $w37 i32) (local $w38 i32) (local $w39 i32)
    (local $w40 i32) (local $w41 i32) (local $w42 i32) (local $w43 i32) 
    (local $w44 i32) (local $w45 i32) (local $w46 i32) (local $w47 i32)
    (local $w48 i32) (local $w49 i32) (local $w50 i32) (local $w51 i32) 
    (local $w52 i32) (local $w53 i32) (local $w54 i32) (local $w55 i32)
    (local $w56 i32) (local $w57 i32) (local $w58 i32) (local $w59 i32) 
    (local $w60 i32) (local $w61 i32) (local $w62 i32) (local $w63 i32)

    ;; load previous hash state into registers
    (global.set $a (i32.load offset=0  (local.get $ctx)))
    (global.set $b (i32.load offset=4  (local.get $ctx)))
    (global.set $c (i32.load offset=8  (local.get $ctx)))
    (global.set $d (i32.load offset=12 (local.get $ctx)))
    (global.set $e (i32.load offset=16 (local.get $ctx)))
    (global.set $f (i32.load offset=20 (local.get $ctx)))
    (global.set $g (i32.load offset=24 (local.get $ctx)))
    (global.set $h (i32.load offset=28 (local.get $ctx)))

    (local.set $w0  (call $i32.bswap (local.get $w0 )))
    (local.set $w1  (call $i32.bswap (local.get $w1 )))
    (local.set $w2  (call $i32.bswap (local.get $w2 )))
    (local.set $w3  (call $i32.bswap (local.get $w3 )))
    (local.set $w4  (call $i32.bswap (local.get $w4 )))
    (local.set $w5  (call $i32.bswap (local.get $w5 )))
    (local.set $w6  (call $i32.bswap (local.get $w6 )))
    (local.set $w7  (call $i32.bswap (local.get $w7 )))
    (local.set $w8  (call $i32.bswap (local.get $w8 )))
    (local.set $w9  (call $i32.bswap (local.get $w9 )))
    (local.set $w10 (call $i32.bswap (local.get $w10)))
    (local.set $w11 (call $i32.bswap (local.get $w11)))
    (local.set $w12 (call $i32.bswap (local.get $w12)))
    (local.set $w13 (call $i32.bswap (local.get $w13)))
    (local.set $w14 (call $i32.bswap (local.get $w14)))
    (local.set $w15 (call $i32.bswap (local.get $w15)))

    (call $four_round (local.get $w0)  (local.get $w1)  (local.get $w2)  (local.get $w3)  (i32.const 0x428a2f98) (i32.const 0x71374491) (i32.const 0xb5c0fbcf) (i32.const 0xe9b5dba5))
    (call $four_round (local.get $w4)  (local.get $w5)  (local.get $w6)  (local.get $w7)  (i32.const 0x3956c25b) (i32.const 0x59f111f1) (i32.const 0x923f82a4) (i32.const 0xab1c5ed5))
    (call $four_round (local.get $w8)  (local.get $w9)  (local.get $w10) (local.get $w11) (i32.const 0xd807aa98) (i32.const 0x12835b01) (i32.const 0x243185be) (i32.const 0x550c7dc3))
    (call $four_round (local.get $w12) (local.get $w13) (local.get $w14) (local.get $w15) (i32.const 0x72be5d74) (i32.const 0x80deb1fe) (i32.const 0x9bdc06a7) (i32.const 0xc19bf174))

    (local.set $w0  (call $expand (local.get $w14) (local.get $w9)  (local.get $w1)  (local.get $w0)))
    (local.set $w1  (call $expand (local.get $w15) (local.get $w10) (local.get $w2)  (local.get $w1)))
    (local.set $w2  (call $expand (local.get $w0 ) (local.get $w11) (local.get $w3)  (local.get $w2)))
    (local.set $w3  (call $expand (local.get $w1 ) (local.get $w12) (local.get $w4)  (local.get $w3)))
    (local.set $w4  (call $expand (local.get $w2 ) (local.get $w13) (local.get $w5)  (local.get $w4)))
    (local.set $w5  (call $expand (local.get $w3 ) (local.get $w14) (local.get $w6)  (local.get $w5)))
    (local.set $w6  (call $expand (local.get $w4 ) (local.get $w15) (local.get $w7)  (local.get $w6)))
    (local.set $w7  (call $expand (local.get $w5 ) (local.get $w0)  (local.get $w8)  (local.get $w7)))
    (local.set $w8  (call $expand (local.get $w6 ) (local.get $w1)  (local.get $w9)  (local.get $w8)))
    (local.set $w9  (call $expand (local.get $w7 ) (local.get $w2)  (local.get $w10) (local.get $w9)))
    (local.set $w10 (call $expand (local.get $w8 ) (local.get $w3)  (local.get $w11) (local.get $w10)))
    (local.set $w11 (call $expand (local.get $w9 ) (local.get $w4)  (local.get $w12) (local.get $w11)))
    (local.set $w12 (call $expand (local.get $w10) (local.get $w5)  (local.get $w13) (local.get $w12)))
    (local.set $w13 (call $expand (local.get $w11) (local.get $w6)  (local.get $w14) (local.get $w13)))
    (local.set $w14 (call $expand (local.get $w12) (local.get $w7)  (local.get $w15) (local.get $w14)))
    (local.set $w15 (call $expand (local.get $w13) (local.get $w8)  (local.get $w0)  (local.get $w15)))

    (call $four_round (local.get $w0)  (local.get $w1)  (local.get $w2)  (local.get $w3)  (i32.const 0xe49b69c1) (i32.const 0xefbe4786) (i32.const 0x0fc19dc6) (i32.const 0x240ca1cc))
    (call $four_round (local.get $w4)  (local.get $w5)  (local.get $w6)  (local.get $w7)  (i32.const 0x2de92c6f) (i32.const 0x4a7484aa) (i32.const 0x5cb0a9dc) (i32.const 0x76f988da))
    (call $four_round (local.get $w8)  (local.get $w9)  (local.get $w10) (local.get $w11) (i32.const 0x983e5152) (i32.const 0xa831c66d) (i32.const 0xb00327c8) (i32.const 0xbf597fc7))
    (call $four_round (local.get $w12) (local.get $w13) (local.get $w14) (local.get $w15) (i32.const 0xc6e00bf3) (i32.const 0xd5a79147) (i32.const 0x06ca6351) (i32.const 0x14292967))

    (local.set $w0  (call $expand (local.get $w14) (local.get $w9)  (local.get $w1)  (local.get $w0)))
    (local.set $w1  (call $expand (local.get $w15) (local.get $w10) (local.get $w2)  (local.get $w1)))
    (local.set $w2  (call $expand (local.get $w0 ) (local.get $w11) (local.get $w3)  (local.get $w2)))
    (local.set $w3  (call $expand (local.get $w1 ) (local.get $w12) (local.get $w4)  (local.get $w3)))
    (local.set $w4  (call $expand (local.get $w2 ) (local.get $w13) (local.get $w5)  (local.get $w4)))
    (local.set $w5  (call $expand (local.get $w3 ) (local.get $w14) (local.get $w6)  (local.get $w5)))
    (local.set $w6  (call $expand (local.get $w4 ) (local.get $w15) (local.get $w7)  (local.get $w6)))
    (local.set $w7  (call $expand (local.get $w5 ) (local.get $w0)  (local.get $w8)  (local.get $w7)))
    (local.set $w8  (call $expand (local.get $w6 ) (local.get $w1)  (local.get $w9)  (local.get $w8)))
    (local.set $w9  (call $expand (local.get $w7 ) (local.get $w2)  (local.get $w10) (local.get $w9)))
    (local.set $w10 (call $expand (local.get $w8 ) (local.get $w3)  (local.get $w11) (local.get $w10)))
    (local.set $w11 (call $expand (local.get $w9 ) (local.get $w4)  (local.get $w12) (local.get $w11)))
    (local.set $w12 (call $expand (local.get $w10) (local.get $w5)  (local.get $w13) (local.get $w12)))
    (local.set $w13 (call $expand (local.get $w11) (local.get $w6)  (local.get $w14) (local.get $w13)))
    (local.set $w14 (call $expand (local.get $w12) (local.get $w7)  (local.get $w15) (local.get $w14)))
    (local.set $w15 (call $expand (local.get $w13) (local.get $w8)  (local.get $w0)  (local.get $w15)))

    (call $four_round (local.get $w0)  (local.get $w1)  (local.get $w2)  (local.get $w3)  (i32.const 0x27b70a85) (i32.const 0x2e1b2138) (i32.const 0x4d2c6dfc) (i32.const 0x53380d13))
    (call $four_round (local.get $w4)  (local.get $w5)  (local.get $w6)  (local.get $w7)  (i32.const 0x650a7354) (i32.const 0x766a0abb) (i32.const 0x81c2c92e) (i32.const 0x92722c85))
    (call $four_round (local.get $w8)  (local.get $w9)  (local.get $w10) (local.get $w11) (i32.const 0xa2bfe8a1) (i32.const 0xa81a664b) (i32.const 0xc24b8b70) (i32.const 0xc76c51a3))
    (call $four_round (local.get $w12) (local.get $w13) (local.get $w14) (local.get $w15) (i32.const 0xd192e819) (i32.const 0xd6990624) (i32.const 0xf40e3585) (i32.const 0x106aa070))

    (local.set $w0  (call $expand (local.get $w14) (local.get $w9)  (local.get $w1)  (local.get $w0)))
    (local.set $w1  (call $expand (local.get $w15) (local.get $w10) (local.get $w2)  (local.get $w1)))
    (local.set $w2  (call $expand (local.get $w0 ) (local.get $w11) (local.get $w3)  (local.get $w2)))
    (local.set $w3  (call $expand (local.get $w1 ) (local.get $w12) (local.get $w4)  (local.get $w3)))
    (local.set $w4  (call $expand (local.get $w2 ) (local.get $w13) (local.get $w5)  (local.get $w4)))
    (local.set $w5  (call $expand (local.get $w3 ) (local.get $w14) (local.get $w6)  (local.get $w5)))
    (local.set $w6  (call $expand (local.get $w4 ) (local.get $w15) (local.get $w7)  (local.get $w6)))
    (local.set $w7  (call $expand (local.get $w5 ) (local.get $w0)  (local.get $w8)  (local.get $w7)))
    (local.set $w8  (call $expand (local.get $w6 ) (local.get $w1)  (local.get $w9)  (local.get $w8)))
    (local.set $w9  (call $expand (local.get $w7 ) (local.get $w2)  (local.get $w10) (local.get $w9)))
    (local.set $w10 (call $expand (local.get $w8 ) (local.get $w3)  (local.get $w11) (local.get $w10)))
    (local.set $w11 (call $expand (local.get $w9 ) (local.get $w4)  (local.get $w12) (local.get $w11)))
    (local.set $w12 (call $expand (local.get $w10) (local.get $w5)  (local.get $w13) (local.get $w12)))
    (local.set $w13 (call $expand (local.get $w11) (local.get $w6)  (local.get $w14) (local.get $w13)))
    (local.set $w14 (call $expand (local.get $w12) (local.get $w7)  (local.get $w15) (local.get $w14)))
    (local.set $w15 (call $expand (local.get $w13) (local.get $w8)  (local.get $w0)  (local.get $w15)))

    (call $four_round (local.get $w0)  (local.get $w1)  (local.get $w2)  (local.get $w3)  (i32.const 0x19a4c116) (i32.const 0x1e376c08) (i32.const 0x2748774c) (i32.const 0x34b0bcb5))
    (call $four_round (local.get $w4)  (local.get $w5)  (local.get $w6)  (local.get $w7)  (i32.const 0x391c0cb3) (i32.const 0x4ed8aa4a) (i32.const 0x5b9cca4f) (i32.const 0x682e6ff3))
    (call $four_round (local.get $w8)  (local.get $w9)  (local.get $w10) (local.get $w11) (i32.const 0x748f82ee) (i32.const 0x78a5636f) (i32.const 0x84c87814) (i32.const 0x8cc70208))
    (call $four_round (local.get $w12) (local.get $w13) (local.get $w14) (local.get $w15) (i32.const 0x90befffa) (i32.const 0xa4506ceb) (i32.const 0xbef9a3f7) (i32.const 0xc67178f2))

    ;; store hash values
    (i32.store offset=0  (local.get $ctx) (i32.add (i32.load offset=0  (local.get $ctx)) (global.get $a)))
    (i32.store offset=4  (local.get $ctx) (i32.add (i32.load offset=4  (local.get $ctx)) (global.get $b)))
    (i32.store offset=8  (local.get $ctx) (i32.add (i32.load offset=8  (local.get $ctx)) (global.get $c)))
    (i32.store offset=12 (local.get $ctx) (i32.add (i32.load offset=12 (local.get $ctx)) (global.get $d)))
    (i32.store offset=16 (local.get $ctx) (i32.add (i32.load offset=16 (local.get $ctx)) (global.get $e)))
    (i32.store offset=20 (local.get $ctx) (i32.add (i32.load offset=20 (local.get $ctx)) (global.get $f)))
    (i32.store offset=24 (local.get $ctx) (i32.add (i32.load offset=24 (local.get $ctx)) (global.get $g)))
    (i32.store offset=28 (local.get $ctx) (i32.add (i32.load offset=28 (local.get $ctx)) (global.get $h))))
        
  (func $sha256 (export "sha256") (param $ctx i32) (param $roi i32) (param $length i32) (param $final i32)
    ;;    schema  208 bytes
    ;;     0..32  hash state
    ;;    32..40  number of bytes read across all updates (128bit)
    ;;   40..104  store words between updates

    (local $bytes_read i64)
    (local $last_word i32)
    (local $tail i32)

    ;; expanded message schedule
    (local $w0 i32)  (local $w1 i32)  (local $w2 i32)  (local $w3 i32)  
    (local $w4 i32)  (local $w5 i32)  (local $w6 i32)  (local $w7 i32) 
    (local $w8 i32)  (local $w9 i32)  (local $w10 i32) (local $w11 i32)
    (local $w12 i32) (local $w13 i32) (local $w14 i32) (local $w15 i32)

    (local.set $bytes_read (i64.load offset=32 (local.get $ctx)))
    (local.set $tail (i32.add (i32.and (i32.wrap_i64 (local.get $bytes_read)) (i32.const 0x3f)) (local.get $length)))

    ;; load current block position
    (local.set $bytes_read (i64.add (local.get $bytes_read) (i64.extend_i32_u (local.get $length))))
    (i64.store offset=32 (local.get $ctx) (local.get $bytes_read))

    (block $finish
      (local.set $w0  (i32.load offset=40 (local.get $ctx)))
      (local.set $w1  (i32.load offset=44 (local.get $ctx)))
      (local.set $w2  (i32.load offset=48 (local.get $ctx)))
      (local.set $w3  (i32.load offset=52 (local.get $ctx)))
      (local.set $w4  (i32.load offset=56 (local.get $ctx)))
      (local.set $w5  (i32.load offset=60 (local.get $ctx)))
      (local.set $w6  (i32.load offset=64 (local.get $ctx)))
      (local.set $w7  (i32.load offset=68 (local.get $ctx)))
      (local.set $w8  (i32.load offset=72 (local.get $ctx)))
      (local.set $w9  (i32.load offset=76 (local.get $ctx)))
      (local.set $w10 (i32.load offset=80 (local.get $ctx)))
      (local.set $w11 (i32.load offset=84 (local.get $ctx)))
      (local.set $w12 (i32.load offset=88 (local.get $ctx)))
      (local.set $w13 (i32.load offset=92 (local.get $ctx)))
      (local.set $w14 (i32.load offset=96 (local.get $ctx)))
      (local.set $w15 (i32.load offset=100 (local.get $ctx)))

      (local.tee $tail (i32.sub (local.get $tail) (i32.const 64)))
      (i32.const 0)
      (i32.lt_s)
      (br_if $finish)

      (local.get $ctx)
      (local.get $w0 )
      (local.get $w1 )
      (local.get $w2 )
      (local.get $w3 )
      (local.get $w4 )
      (local.get $w5 )
      (local.get $w6 )
      (local.get $w7 )
      (local.get $w8 )
      (local.get $w9 )
      (local.get $w10)
      (local.get $w11)
      (local.get $w12)
      (local.get $w13)
      (local.get $w14)
      (local.get $w15)
      (call $compress)

      (loop $rest_of_input
        (local.set $w0  (i32.load offset=0  (local.get $roi)))
        (local.set $w1  (i32.load offset=4  (local.get $roi)))
        (local.set $w2  (i32.load offset=8  (local.get $roi)))
        (local.set $w3  (i32.load offset=12 (local.get $roi)))
        (local.set $w4  (i32.load offset=16 (local.get $roi)))
        (local.set $w5  (i32.load offset=20 (local.get $roi)))
        (local.set $w6  (i32.load offset=24 (local.get $roi)))
        (local.set $w7  (i32.load offset=28 (local.get $roi)))
        (local.set $w8  (i32.load offset=32 (local.get $roi)))
        (local.set $w9  (i32.load offset=36 (local.get $roi)))
        (local.set $w10 (i32.load offset=40 (local.get $roi)))
        (local.set $w11 (i32.load offset=44 (local.get $roi)))
        (local.set $w12 (i32.load offset=48 (local.get $roi)))
        (local.set $w13 (i32.load offset=52 (local.get $roi)))
        (local.set $w14 (i32.load offset=56 (local.get $roi)))
        (local.set $w15 (i32.load offset=60 (local.get $roi)))

        (local.set $roi (i32.add (local.get $roi) (i32.const 64)))

        (local.tee $tail (i32.sub (local.get $tail) (i32.const 64)))
        (i32.const 0)
        (i32.lt_s)
        (if
          (then
            (i32.store offset=40 (local.get $ctx) (local.get $w0))
            (i32.store offset=44 (local.get $ctx) (local.get $w1))
            (i32.store offset=48 (local.get $ctx) (local.get $w2))
            (i32.store offset=52 (local.get $ctx) (local.get $w3))
            (i32.store offset=56 (local.get $ctx) (local.get $w4))
            (i32.store offset=60 (local.get $ctx) (local.get $w5))
            (i32.store offset=64 (local.get $ctx) (local.get $w6))
            (i32.store offset=68 (local.get $ctx) (local.get $w7))
            (i32.store offset=72 (local.get $ctx) (local.get $w8))
            (i32.store offset=76 (local.get $ctx) (local.get $w9))
            (i32.store offset=80 (local.get $ctx) (local.get $w10))
            (i32.store offset=84 (local.get $ctx) (local.get $w11))
            (i32.store offset=88 (local.get $ctx) (local.get $w12))
            (i32.store offset=92 (local.get $ctx) (local.get $w13))
            (i32.store offset=96 (local.get $ctx) (local.get $w14))
            (i32.store offset=100 (local.get $ctx) (local.get $w15))
            (br $finish)))

        (local.get $ctx)
        (local.get $w0 )
        (local.get $w1 )
        (local.get $w2 )
        (local.get $w3 )
        (local.get $w4 )
        (local.get $w5 )
        (local.get $w6 )
        (local.get $w7 )
        (local.get $w8 )
        (local.get $w9 )
        (local.get $w10)
        (local.get $w11)
        (local.get $w12)
        (local.get $w13)
        (local.get $w14)
        (local.get $w15)
        (call $compress)

        (br $rest_of_input)))

    (if (i32.eq (local.get $final) (i32.const 1))
      (then
        (local.set $tail (i32.and (i32.wrap_i64 (local.get $bytes_read)) (i32.const 0x3f)))
        (local.set $last_word (i32.shl (i32.const 0x80) (i32.shl (i32.and (local.get $tail) (i32.const 0x3)) (i32.const 3))))

        (block $pad_end
                (block $13
                    (block $12
                        (block $11
                            (block $10
                                (block $9
                                    (block $8
                                        (block $7
                                            (block $6
                                                (block $5
                                                    (block $4
                                                        (block $3
                                                            (block $2
                                                                (block $1
                                                                    (block $0
                                                                        (block $15
                                                                            (block $14
                                                                                (block $switch
                                                                                    (local.get $tail)
                                                                                    (i32.const 2)
                                                                                    (i32.shr_u)
                                                                                    (br_table $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15)))
                                                                                
                                                                                (local.get $last_word)
                                                                                (local.get $w14)
                                                                                (i32.or)
                                                                                (local.set $w14)
                                                                                (local.set $last_word (i32.const 0)))
                                                                            
                                                                            (local.get $last_word)
                                                                            (local.get $w15)
                                                                            (i32.or)
                                                                            (local.set $w15)
                                                                            (local.set $last_word (i32.const 0))

                                                                            ;; compress
                                                                            (local.get $ctx)
                                                                            (local.get $w0)
                                                                            (local.get $w1)
                                                                            (local.get $w2)
                                                                            (local.get $w3)
                                                                            (local.get $w4)
                                                                            (local.get $w5)
                                                                            (local.get $w6)
                                                                            (local.get $w7)
                                                                            (local.get $w8)
                                                                            (local.get $w9)
                                                                            (local.get $w10)
                                                                            (local.get $w11)
                                                                            (local.get $w12)
                                                                            (local.get $w13)
                                                                            (local.get $w14)
                                                                            (local.get $w15)
                                                                            (call $compress)

                                                                            (i64.store offset=32 (local.get $ctx) (local.get $bytes_read))

                                                                            ;; zero out words
                                                                            (local.set $w0  (i32.const 0))
                                                                            (local.set $w1  (i32.const 0))
                                                                            (local.set $w2  (i32.const 0))
                                                                            (local.set $w3  (i32.const 0))
                                                                            (local.set $w4  (i32.const 0))
                                                                            (local.set $w5  (i32.const 0))
                                                                            (local.set $w6  (i32.const 0))
                                                                            (local.set $w7  (i32.const 0))
                                                                            (local.set $w8  (i32.const 0))
                                                                            (local.set $w9  (i32.const 0))
                                                                            (local.set $w10 (i32.const 0))
                                                                            (local.set $w11 (i32.const 0))
                                                                            (local.set $w12 (i32.const 0))
                                                                            (local.set $w13 (i32.const 0))
                                                                            (local.set $w14 (i32.const 0))
                                                                            (local.set $w15 (i32.const 0)))
                                                                        
                                                                        (local.get $last_word)
                                                                        (local.get $w0)
                                                                        (i32.or)
                                                                        (local.set $w0)
                                                                        (local.set $last_word (i32.const 0)))
                                                                    
                                                                    (local.get $last_word)
                                                                    (local.get $w1)
                                                                    (i32.or)
                                                                    (local.set $w1)
                                                                    (local.set $last_word (i32.const 0)))
                                                                
                                                                (local.get $last_word)
                                                                (local.get $w2)
                                                                (i32.or)
                                                                (local.set $w2)
                                                                (local.set $last_word (i32.const 0)))
                                                            
                                                            (local.get $last_word)
                                                            (local.get $w3)
                                                            (i32.or)
                                                            (local.set $w3)
                                                            (local.set $last_word (i32.const 0)))
                                                        
                                                        (local.get $last_word)
                                                        (local.get $w4)
                                                        (i32.or)
                                                        (local.set $w4)
                                                        (local.set $last_word (i32.const 0)))
                                                    
                                                    (local.get $last_word)
                                                    (local.get $w5)
                                                    (i32.or)
                                                    (local.set $w5)
                                                    (local.set $last_word (i32.const 0)))
                                                
                                                (local.get $last_word)
                                                (local.get $w6)
                                                (i32.or)
                                                (local.set $w6)
                                                (local.set $last_word (i32.const 0)))
                                            
                                            (local.get $last_word)
                                            (local.get $w7)
                                            (i32.or)
                                            (local.set $w7)
                                            (local.set $last_word (i32.const 0)))
                                        
                                        (local.get $last_word)
                                        (local.get $w8)
                                        (i32.or)
                                        (local.set $w8)
                                        (local.set $last_word (i32.const 0)))
                                    
                                    (local.get $last_word)
                                    (local.get $w9)
                                    (i32.or)
                                    (local.set $w9)
                                    (local.set $last_word (i32.const 0)))
                                
                                (local.get $last_word)
                                (local.get $w10)
                                (i32.or)
                                (local.set $w10)
                                (local.set $last_word (i32.const 0)))
                            
                            (local.get $last_word)
                            (local.get $w11)
                            (i32.or)
                            (local.set $w11)
                            (local.set $last_word (i32.const 0)))
                        
                        (local.get $last_word)
                        (local.get $w12)
                        (i32.or)
                        (local.set $w12)
                        (local.set $last_word (i32.const 0)))
                    
                    (local.get $last_word)
                    (local.get $w13)
                    (i32.or)
                    (local.set $w13)
                    (local.set $last_word (i32.const 0)))
            
            (local.set $w14 (call $i32.bswap (i32.wrap_i64 (i64.shr_u (local.get $bytes_read) (i64.const 29)))))
            (local.set $w15 (call $i32.bswap (i32.wrap_i64 (i64.shl (local.get $bytes_read) (i64.const 3)))))

            (local.get $ctx)
            (local.get $w0)
            (local.get $w1)
            (local.get $w2)
            (local.get $w3)
            (local.get $w4)
            (local.get $w5)
            (local.get $w6)
            (local.get $w7)
            (local.get $w8)
            (local.get $w9)
            (local.get $w10)
            (local.get $w11)
            (local.get $w12)
            (local.get $w13)
            (local.get $w14)
            (local.get $w15)
            (call $compress)

            (local.get $ctx)
            (i32.load offset=0 (local.get $ctx))
            (call $i32.bswap)
            (i32.store offset=0)

            (local.get $ctx)
            (i32.load offset=4 (local.get $ctx))
            (call $i32.bswap)
            (i32.store offset=4)

            (local.get $ctx)
            (i32.load offset=8 (local.get $ctx))
            (call $i32.bswap)
            (i32.store offset=8)

            (local.get $ctx)
            (i32.load offset=12 (local.get $ctx))
            (call $i32.bswap)
            (i32.store offset=12)

            (local.get $ctx)
            (i32.load offset=16 (local.get $ctx))
            (call $i32.bswap)
            (i32.store offset=16)

            (local.get $ctx)
            (i32.load offset=20 (local.get $ctx))
            (call $i32.bswap)
            (i32.store offset=20)

            (local.get $ctx)
            (i32.load offset=24 (local.get $ctx))
            (call $i32.bswap)
            (i32.store offset=24)

            (local.get $ctx)
            (i32.load offset=28 (local.get $ctx))
            (call $i32.bswap)
            (i32.store offset=28)))))
