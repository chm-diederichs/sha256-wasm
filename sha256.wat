(module
  (memory (export "memory") 10 1000)
    
  (func (export "sha256_init") (param $ptr i32)
    ;; setup param block (expect memory to be cleared)
    ;; hash array 0-32
    (i32.store offset=0  (get_local $ptr) (i32.xor (i32.const 0x6a09e667) (i32.const 0)))
    (i32.store offset=4  (get_local $ptr) (i32.xor (i32.const 0xbb67ae85) (i32.const 0)))
    (i32.store offset=8  (get_local $ptr) (i32.xor (i32.const 0x3c6ef372) (i32.const 0)))
    (i32.store offset=12 (get_local $ptr) (i32.xor (i32.const 0xa54ff53a) (i32.const 0)))
    (i32.store offset=16 (get_local $ptr) (i32.xor (i32.const 0x510e527f) (i32.const 0)))
    (i32.store offset=20 (get_local $ptr) (i32.xor (i32.const 0x9b05688c) (i32.const 0)))
    (i32.store offset=24 (get_local $ptr) (i32.xor (i32.const 0x1f83d9ab) (i32.const 0)))
    (i32.store offset=28 (get_local $ptr) (i32.xor (i32.const 0x5be0cd19) (i32.const 0)))

    ;; load word constants 32-288
    (i32.store offset=32 (get_local $ptr) (i32.xor (i32.const 0x428a2f98) (i32.const 0)))
    (i32.store offset=36 (get_local $ptr) (i32.xor (i32.const 0x71374491) (i32.const 0)))
    (i32.store offset=40 (get_local $ptr) (i32.xor (i32.const 0xb5c0fbcf) (i32.const 0)))
    (i32.store offset=44 (get_local $ptr) (i32.xor (i32.const 0xe9b5dba5) (i32.const 0)))
    (i32.store offset=48 (get_local $ptr) (i32.xor (i32.const 0x3956c25b) (i32.const 0)))
    (i32.store offset=52 (get_local $ptr) (i32.xor (i32.const 0x59f111f1) (i32.const 0)))
    (i32.store offset=56 (get_local $ptr) (i32.xor (i32.const 0x923f82a4) (i32.const 0)))
    (i32.store offset=60 (get_local $ptr) (i32.xor (i32.const 0xab1c5ed5) (i32.const 0)))
    (i32.store offset=64 (get_local $ptr) (i32.xor (i32.const 0xd807aa98) (i32.const 0)))
    (i32.store offset=68 (get_local $ptr) (i32.xor (i32.const 0x12835b01) (i32.const 0)))
    (i32.store offset=72 (get_local $ptr) (i32.xor (i32.const 0x243185be) (i32.const 0)))
    (i32.store offset=76 (get_local $ptr) (i32.xor (i32.const 0x550c7dc3) (i32.const 0)))
    (i32.store offset=80 (get_local $ptr) (i32.xor (i32.const 0x72be5d74) (i32.const 0)))
    (i32.store offset=84 (get_local $ptr) (i32.xor (i32.const 0x80deb1fe) (i32.const 0)))
    (i32.store offset=88 (get_local $ptr) (i32.xor (i32.const 0x9bdc06a7) (i32.const 0)))
    (i32.store offset=92 (get_local $ptr) (i32.xor (i32.const 0xc19bf174) (i32.const 0)))
    (i32.store offset=96 (get_local $ptr) (i32.xor (i32.const 0xe49b69c1) (i32.const 0)))
    (i32.store offset=100 (get_local $ptr) (i32.xor (i32.const 0xefbe4786) (i32.const 0)))
    (i32.store offset=104 (get_local $ptr) (i32.xor (i32.const 0x0fc19dc6) (i32.const 0)))
    (i32.store offset=108 (get_local $ptr) (i32.xor (i32.const 0x240ca1cc) (i32.const 0)))
    (i32.store offset=112 (get_local $ptr) (i32.xor (i32.const 0x2de92c6f) (i32.const 0)))
    (i32.store offset=116 (get_local $ptr) (i32.xor (i32.const 0x4a7484aa) (i32.const 0)))
    (i32.store offset=120 (get_local $ptr) (i32.xor (i32.const 0x5cb0a9dc) (i32.const 0)))
    (i32.store offset=124 (get_local $ptr) (i32.xor (i32.const 0x76f988da) (i32.const 0)))
    (i32.store offset=128 (get_local $ptr) (i32.xor (i32.const 0x983e5152) (i32.const 0)))
    (i32.store offset=132 (get_local $ptr) (i32.xor (i32.const 0xa831c66d) (i32.const 0)))
    (i32.store offset=136 (get_local $ptr) (i32.xor (i32.const 0xb00327c8) (i32.const 0)))
    (i32.store offset=140 (get_local $ptr) (i32.xor (i32.const 0xbf597fc7) (i32.const 0)))
    (i32.store offset=144 (get_local $ptr) (i32.xor (i32.const 0xc6e00bf3) (i32.const 0)))
    (i32.store offset=148 (get_local $ptr) (i32.xor (i32.const 0xd5a79147) (i32.const 0)))
    (i32.store offset=152 (get_local $ptr) (i32.xor (i32.const 0x06ca6351) (i32.const 0)))
    (i32.store offset=156 (get_local $ptr) (i32.xor (i32.const 0x14292967) (i32.const 0)))
    (i32.store offset=160 (get_local $ptr) (i32.xor (i32.const 0x27b70a85) (i32.const 0)))
    (i32.store offset=164 (get_local $ptr) (i32.xor (i32.const 0x2e1b2138) (i32.const 0)))
    (i32.store offset=168 (get_local $ptr) (i32.xor (i32.const 0x4d2c6dfc) (i32.const 0)))
    (i32.store offset=172 (get_local $ptr) (i32.xor (i32.const 0x53380d13) (i32.const 0)))
    (i32.store offset=176 (get_local $ptr) (i32.xor (i32.const 0x650a7354) (i32.const 0)))
    (i32.store offset=180 (get_local $ptr) (i32.xor (i32.const 0x766a0abb) (i32.const 0)))
    (i32.store offset=184 (get_local $ptr) (i32.xor (i32.const 0x81c2c92e) (i32.const 0)))
    (i32.store offset=188 (get_local $ptr) (i32.xor (i32.const 0x92722c85) (i32.const 0)))
    (i32.store offset=192 (get_local $ptr) (i32.xor (i32.const 0xa2bfe8a1) (i32.const 0)))
    (i32.store offset=196 (get_local $ptr) (i32.xor (i32.const 0xa81a664b) (i32.const 0)))
    (i32.store offset=200 (get_local $ptr) (i32.xor (i32.const 0xc24b8b70) (i32.const 0)))
    (i32.store offset=204 (get_local $ptr) (i32.xor (i32.const 0xc76c51a3) (i32.const 0)))
    (i32.store offset=208 (get_local $ptr) (i32.xor (i32.const 0xd192e819) (i32.const 0)))
    (i32.store offset=212 (get_local $ptr) (i32.xor (i32.const 0xd6990624) (i32.const 0)))
    (i32.store offset=216 (get_local $ptr) (i32.xor (i32.const 0xf40e3585) (i32.const 0)))
    (i32.store offset=220 (get_local $ptr) (i32.xor (i32.const 0x106aa070) (i32.const 0)))
    (i32.store offset=224 (get_local $ptr) (i32.xor (i32.const 0x19a4c116) (i32.const 0)))
    (i32.store offset=228 (get_local $ptr) (i32.xor (i32.const 0x1e376c08) (i32.const 0)))
    (i32.store offset=232 (get_local $ptr) (i32.xor (i32.const 0x2748774c) (i32.const 0)))
    (i32.store offset=236 (get_local $ptr) (i32.xor (i32.const 0x34b0bcb5) (i32.const 0)))
    (i32.store offset=240 (get_local $ptr) (i32.xor (i32.const 0x391c0cb3) (i32.const 0)))
    (i32.store offset=244 (get_local $ptr) (i32.xor (i32.const 0x4ed8aa4a) (i32.const 0)))
    (i32.store offset=248 (get_local $ptr) (i32.xor (i32.const 0x5b9cca4f) (i32.const 0)))
    (i32.store offset=252 (get_local $ptr) (i32.xor (i32.const 0x682e6ff3) (i32.const 0)))
    (i32.store offset=256 (get_local $ptr) (i32.xor (i32.const 0x748f82ee) (i32.const 0)))
    (i32.store offset=260 (get_local $ptr) (i32.xor (i32.const 0x78a5636f) (i32.const 0)))
    (i32.store offset=264 (get_local $ptr) (i32.xor (i32.const 0x84c87814) (i32.const 0)))
    (i32.store offset=268 (get_local $ptr) (i32.xor (i32.const 0x8cc70208) (i32.const 0)))
    (i32.store offset=272 (get_local $ptr) (i32.xor (i32.const 0x90befffa) (i32.const 0)))
    (i32.store offset=276 (get_local $ptr) (i32.xor (i32.const 0xa4506ceb) (i32.const 0)))
    (i32.store offset=280 (get_local $ptr) (i32.xor (i32.const 0xbef9a3f7) (i32.const 0)))
    (i32.store offset=284 (get_local $ptr) (i32.xor (i32.const 0xc67178f2) (i32.const 0))))

  (func $Ch (param $x i32) (param $y i32) (param $z i32)
    (result i32)

    (i32.xor 
      (i32.and (get_local $x) (get_local $y))             
      (i32.and 
        (i32.xor (get_local $x) (i32.const -1))
        (get_local $y))))
 
  (func $Maj (param $x i32) (param $y i32) (param $z i32)
    (result i32)

    (i32.xor
      (i32.xor
        (i32.and (get_local $x) (get_local $y))
        (i32.and (get_local $x) (get_local $z)))
      (i32.and (get_local $y) (get_local $z))))
  
  (func $big_sig0 (param $x i32)
    (result i32)

    (i32.xor
      (i32.xor
        (i32.rotr (get_local $x) (i32.const 2))
        (i32.rotr (get_local $x) (i32.const 13)))
      (i32.rotr (get_local $x) (i32.const 22))))

  (func $big_sig1 (param $x i32)
    (result i32)

    (i32.xor
      (i32.xor
        (i32.rotr (get_local $x) (i32.const 6))
        (i32.rotr (get_local $x) (i32.const 11)))
      (i32.rotr (get_local $x) (i32.const 25))))

  (func $sig0 (param $x i32)
    (result i32)

    (i32.xor
      (i32.xor
        (i32.rotr (get_local $x) (i32.const 7))
        (i32.rotr (get_local $x) (i32.const 18)))
      (i32.rotr (get_local $x) (i32.const 3))))

  (func $sig1 (param $x i32)
    (result i32)

    (i32.xor
      (i32.xor
        (i32.rotr (get_local $x) (i32.const 17))
        (i32.rotr (get_local $x) (i32.const 19)))
      (i32.shr_u (get_local $x) (i32.const 10))))

  (func $sha256_update (export "sha256_update") (param $ptr i32)
    ;; registers
    (local $r0 i32)
    (local $r1 i32)
    (local $r2 i32)
    (local $r3 i32)
    (local $r4 i32)
    (local $r5 i32)
    (local $r6 i32)
    (local $r7 i32)

    ;; precomputed values
    (local $T1 i32)
    (local $T2 i32)

    (local $ch_res i32)
    (local $maj_res i32)
    (local $big_sig0_res i32)
    (local $big_sig1_res i32)

    ;; expanded message schedule
    (local $w0 i32) 
    (local $w1 i32) 
    (local $w2 i32) 
    (local $w3 i32) 
    (local $w4 i32) 
    (local $w5 i32) 
    (local $w6 i32) 
    (local $w7 i32) 
    (local $w8 i32) 
    (local $w9 i32) 
    (local $w10 i32)
    (local $w11 i32)
    (local $w12 i32)
    (local $w13 i32)
    (local $w14 i32)
    (local $w15 i32)
    (local $w16 i32)
    (local $w17 i32)
    (local $w18 i32)
    (local $w19 i32)
    (local $w20 i32)
    (local $w21 i32)
    (local $w22 i32)
    (local $w23 i32)
    (local $w24 i32)
    (local $w25 i32)
    (local $w26 i32)
    (local $w27 i32)
    (local $w28 i32)
    (local $w29 i32)
    (local $w30 i32)
    (local $w31 i32)
    (local $w32 i32)
    (local $w33 i32)
    (local $w34 i32)
    (local $w35 i32)
    (local $w36 i32)
    (local $w37 i32)
    (local $w38 i32)
    (local $w39 i32)
    (local $w40 i32)
    (local $w41 i32)
    (local $w42 i32)
    (local $w43 i32)
    (local $w44 i32)
    (local $w45 i32)
    (local $w46 i32)
    (local $w47 i32)
    (local $w48 i32)
    (local $w49 i32)
    (local $w50 i32)
    (local $w51 i32)
    (local $w52 i32)
    (local $w53 i32)
    (local $w54 i32)
    (local $w55 i32)
    (local $w56 i32)
    (local $w57 i32)
    (local $w58 i32)
    (local $w59 i32)
    (local $w60 i32)
    (local $w61 i32)
    (local $w62 i32)
    (local $w63 i32)

    ;; message loaded at ptr + 32-96
    (set_local $w0 (i32.load offset=32 (get_local $ptr)))
    (set_local $w1 (i32.load offset=36 (get_local $ptr)))
    (set_local $w2 (i32.load offset=40 (get_local $ptr)))
    (set_local $w3 (i32.load offset=44 (get_local $ptr)))
    (set_local $w4 (i32.load offset=48 (get_local $ptr)))
    (set_local $w5 (i32.load offset=52 (get_local $ptr)))
    (set_local $w6 (i32.load offset=56 (get_local $ptr)))
    (set_local $w7 (i32.load offset=60 (get_local $ptr)))
    (set_local $w8 (i32.load offset=64 (get_local $ptr)))
    (set_local $w9 (i32.load offset=68 (get_local $ptr)))
    (set_local $w10 (i32.load offset=72 (get_local $ptr)))
    (set_local $w11 (i32.load offset=76 (get_local $ptr)))
    (set_local $w12 (i32.load offset=80 (get_local $ptr)))
    (set_local $w13 (i32.load offset=84 (get_local $ptr)))
    (set_local $w14 (i32.load offset=88 (get_local $ptr)))
    (set_local $w15 (i32.load offset=92 (get_local $ptr)))
    
    ;; words 16-63 are defined by w[j] <- sig1(w[j-2]) + w[j-7] + sig0(w[j-15]) + w[j-16]
    (set_local $w16 (i32.add (i32.add (i32.add (call $sig1 (get_local $w14)) (get_local $w9)) (call $sig0 (get_local $w1)) (get_local $w0))))
    (set_local $w17 (i32.add (i32.add (i32.add (call $sig1 (get_local $w15)) (get_local $w10)) (call $sig0 (get_local $w2)) (get_local $w1))))
    (set_local $w18 (i32.add (i32.add (i32.add (call $sig1 (get_local $w16)) (get_local $w11)) (call $sig0 (get_local $w3)) (get_local $w2))))
    (set_local $w19 (i32.add (i32.add (i32.add (call $sig1 (get_local $w17)) (get_local $w12)) (call $sig0 (get_local $w4)) (get_local $w3))))
    (set_local $w20 (i32.add (i32.add (i32.add (call $sig1 (get_local $w18)) (get_local $w13)) (call $sig0 (get_local $w5)) (get_local $w4))))
    (set_local $w21 (i32.add (i32.add (i32.add (call $sig1 (get_local $w19)) (get_local $w14)) (call $sig0 (get_local $w6)) (get_local $w5))))
    (set_local $w22 (i32.add (i32.add (i32.add (call $sig1 (get_local $w20)) (get_local $w15)) (call $sig0 (get_local $w7)) (get_local $w6))))
    (set_local $w23 (i32.add (i32.add (i32.add (call $sig1 (get_local $w21)) (get_local $w16)) (call $sig0 (get_local $w8)) (get_local $w7))))
    (set_local $w24 (i32.add (i32.add (i32.add (call $sig1 (get_local $w22)) (get_local $w17)) (call $sig0 (get_local $w9)) (get_local $w8))))
    (set_local $w25 (i32.add (i32.add (i32.add (call $sig1 (get_local $w23)) (get_local $w18)) (call $sig0 (get_local $w10)) (get_local $w9))))
    (set_local $w26 (i32.add (i32.add (i32.add (call $sig1 (get_local $w24)) (get_local $w19)) (call $sig0 (get_local $w11)) (get_local $w10))))
    (set_local $w27 (i32.add (i32.add (i32.add (call $sig1 (get_local $w25)) (get_local $w20)) (call $sig0 (get_local $w12)) (get_local $w11))))
    (set_local $w28 (i32.add (i32.add (i32.add (call $sig1 (get_local $w26)) (get_local $w21)) (call $sig0 (get_local $w13)) (get_local $w12))))
    (set_local $w29 (i32.add (i32.add (i32.add (call $sig1 (get_local $w27)) (get_local $w22)) (call $sig0 (get_local $w14)) (get_local $w13))))
    (set_local $w30 (i32.add (i32.add (i32.add (call $sig1 (get_local $w28)) (get_local $w23)) (call $sig0 (get_local $w15)) (get_local $w14))))
    (set_local $w31 (i32.add (i32.add (i32.add (call $sig1 (get_local $w29)) (get_local $w24)) (call $sig0 (get_local $w16)) (get_local $w15))))
    (set_local $w32 (i32.add (i32.add (i32.add (call $sig1 (get_local $w30)) (get_local $w25)) (call $sig0 (get_local $w17)) (get_local $w16))))
    (set_local $w33 (i32.add (i32.add (i32.add (call $sig1 (get_local $w31)) (get_local $w26)) (call $sig0 (get_local $w18)) (get_local $w17))))
    (set_local $w34 (i32.add (i32.add (i32.add (call $sig1 (get_local $w32)) (get_local $w27)) (call $sig0 (get_local $w19)) (get_local $w18))))
    (set_local $w35 (i32.add (i32.add (i32.add (call $sig1 (get_local $w33)) (get_local $w28)) (call $sig0 (get_local $w20)) (get_local $w19))))
    (set_local $w36 (i32.add (i32.add (i32.add (call $sig1 (get_local $w34)) (get_local $w29)) (call $sig0 (get_local $w21)) (get_local $w20))))
    (set_local $w37 (i32.add (i32.add (i32.add (call $sig1 (get_local $w35)) (get_local $w30)) (call $sig0 (get_local $w22)) (get_local $w21))))
    (set_local $w38 (i32.add (i32.add (i32.add (call $sig1 (get_local $w36)) (get_local $w31)) (call $sig0 (get_local $w23)) (get_local $w22))))
    (set_local $w39 (i32.add (i32.add (i32.add (call $sig1 (get_local $w37)) (get_local $w32)) (call $sig0 (get_local $w24)) (get_local $w23))))
    (set_local $w40 (i32.add (i32.add (i32.add (call $sig1 (get_local $w38)) (get_local $w33)) (call $sig0 (get_local $w25)) (get_local $w24))))
    (set_local $w41 (i32.add (i32.add (i32.add (call $sig1 (get_local $w39)) (get_local $w34)) (call $sig0 (get_local $w26)) (get_local $w25))))
    (set_local $w42 (i32.add (i32.add (i32.add (call $sig1 (get_local $w40)) (get_local $w35)) (call $sig0 (get_local $w27)) (get_local $w26))))
    (set_local $w43 (i32.add (i32.add (i32.add (call $sig1 (get_local $w41)) (get_local $w36)) (call $sig0 (get_local $w28)) (get_local $w27))))
    (set_local $w44 (i32.add (i32.add (i32.add (call $sig1 (get_local $w42)) (get_local $w37)) (call $sig0 (get_local $w29)) (get_local $w28))))
    (set_local $w45 (i32.add (i32.add (i32.add (call $sig1 (get_local $w43)) (get_local $w38)) (call $sig0 (get_local $w30)) (get_local $w29))))
    (set_local $w46 (i32.add (i32.add (i32.add (call $sig1 (get_local $w44)) (get_local $w39)) (call $sig0 (get_local $w31)) (get_local $w30))))
    (set_local $w47 (i32.add (i32.add (i32.add (call $sig1 (get_local $w45)) (get_local $w40)) (call $sig0 (get_local $w32)) (get_local $w31))))
    (set_local $w48 (i32.add (i32.add (i32.add (call $sig1 (get_local $w46)) (get_local $w41)) (call $sig0 (get_local $w33)) (get_local $w32))))
    (set_local $w49 (i32.add (i32.add (i32.add (call $sig1 (get_local $w47)) (get_local $w42)) (call $sig0 (get_local $w34)) (get_local $w33))))
    (set_local $w50 (i32.add (i32.add (i32.add (call $sig1 (get_local $w48)) (get_local $w43)) (call $sig0 (get_local $w35)) (get_local $w34))))
    (set_local $w51 (i32.add (i32.add (i32.add (call $sig1 (get_local $w49)) (get_local $w44)) (call $sig0 (get_local $w36)) (get_local $w35))))
    (set_local $w52 (i32.add (i32.add (i32.add (call $sig1 (get_local $w50)) (get_local $w45)) (call $sig0 (get_local $w37)) (get_local $w36))))
    (set_local $w53 (i32.add (i32.add (i32.add (call $sig1 (get_local $w51)) (get_local $w46)) (call $sig0 (get_local $w38)) (get_local $w37))))
    (set_local $w54 (i32.add (i32.add (i32.add (call $sig1 (get_local $w52)) (get_local $w47)) (call $sig0 (get_local $w39)) (get_local $w38))))
    (set_local $w55 (i32.add (i32.add (i32.add (call $sig1 (get_local $w53)) (get_local $w48)) (call $sig0 (get_local $w40)) (get_local $w39))))
    (set_local $w56 (i32.add (i32.add (i32.add (call $sig1 (get_local $w54)) (get_local $w49)) (call $sig0 (get_local $w41)) (get_local $w40))))
    (set_local $w57 (i32.add (i32.add (i32.add (call $sig1 (get_local $w55)) (get_local $w50)) (call $sig0 (get_local $w42)) (get_local $w41))))
    (set_local $w58 (i32.add (i32.add (i32.add (call $sig1 (get_local $w56)) (get_local $w51)) (call $sig0 (get_local $w43)) (get_local $w42))))
    (set_local $w59 (i32.add (i32.add (i32.add (call $sig1 (get_local $w57)) (get_local $w52)) (call $sig0 (get_local $w44)) (get_local $w43))))
    (set_local $w60 (i32.add (i32.add (i32.add (call $sig1 (get_local $w58)) (get_local $w53)) (call $sig0 (get_local $w45)) (get_local $w44))))
    (set_local $w61 (i32.add (i32.add (i32.add (call $sig1 (get_local $w59)) (get_local $w54)) (call $sig0 (get_local $w46)) (get_local $w45))))
    (set_local $w62 (i32.add (i32.add (i32.add (call $sig1 (get_local $w60)) (get_local $w55)) (call $sig0 (get_local $w47)) (get_local $w46))))
    (set_local $w63 (i32.add (i32.add (i32.add (call $sig1 (get_local $w61)) (get_local $w56)) (call $sig0 (get_local $w48)) (get_local $w47))))

    ;; (func $sha256_compress (export "sha256_compress") (param $)))
    
    ;; (func $update (export "update") (param $ptr i32)

    ;; load previous hash state
    (set_local $r0 (i32.load offset=0 (get_local $ptr)))
    (set_local $r1 (i32.load offset=4 (get_local $ptr)))
    (set_local $r2 (i32.load offset=8 (get_local $ptr)))
    (set_local $r3 (i32.load offset=12 (get_local $ptr)))
    (set_local $r4 (i32.load offset=16 (get_local $ptr)))
    (set_local $r5 (i32.load offset=20 (get_local $ptr)))
    (set_local $r6 (i32.load offset=24 (get_local $ptr)))
    (set_local $r7 (i32.load offset=28 (get_local $ptr)))
    

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    
    ;; ROUND 0

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K0 + W0
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w0)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 1

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K1 + W1
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w1)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 2

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K2 + W2
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w2)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 3

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K3 + W3
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w3)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 4

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K4 + W4
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w4)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 5

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K5 + W5
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w5)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 6

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K6 + W6
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w6)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 7

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K7 + W7
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w7)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 8

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K8 + W8
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w8)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 9

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K9 + W9
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w9)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 10

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K10 + W10
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w10)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 11

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K11 + W11
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w11)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 12

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K12 + W12
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w12)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 13

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K13 + W13
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w13)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 14

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K14 + W14
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w14)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 15

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K15 + W15
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w15)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 16

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K16 + W16
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w16)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 17

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K17 + W17
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w17)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 18

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K18 + W18
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w18)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 19

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K19 + W19
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w19)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 20

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K20 + W20
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w20)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 21

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K21 + W21
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w21)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 22

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K22 + W22
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w22)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 23

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K23 + W23
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w23)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 24

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K24 + W24
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w24)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 25

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K25 + W25
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w25)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 26

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K26 + W26
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w26)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 27

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K27 + W27
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w27)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 28

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K28 + W28
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w28)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 29

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K29 + W29
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w29)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 30

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K30 + W30
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w30)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 31

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K31 + W31
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w31)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 32

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K32 + W32
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w32)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 33

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K33 + W33
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w33)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 34

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K34 + W34
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w34)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 35

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K35 + W35
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w35)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 36

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K36 + W36
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w36)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 37

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K37 + W37
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w37)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 38

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K38 + W38
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w38)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 39

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K39 + W39
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w39)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 40

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K40 + W40
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w40)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 41

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K41 + W41
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w41)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 42

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K42 + W42
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w42)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 43

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K43 + W43
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w43)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 44

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K44 + W44
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w44)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 45

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K45 + W45
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w45)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 46

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K46 + W46
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w46)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 47

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K47 + W47
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w47)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 48

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K48 + W48
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w48)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 49

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K49 + W49
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w49)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 50

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K50 + W50
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w50)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 51

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K51 + W51
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w51)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 52

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K52 + W52
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w52)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 53

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K53 + W53
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w53)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 54

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K54 + W54
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w54)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 55

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K55 + W55
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w55)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 56

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K56 + W56
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w56)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 57

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K57 + W57
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w57)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 58

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K58 + W58
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w58)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 59

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K59 + W59
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w59)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 60

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K60 + W60
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w60)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 61

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K61 + W61
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w61)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 62

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K62 + W62
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w62)) (i32.load offset=32 (get_local $ptr))))
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

    ;; ROUND 63

    ;; precompute intermediate values

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $r0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $r4)))

    ;; T1 = h + big_sig1(e) + ch(e, f, g) + K63 + W63
    ;; T2 = big_sig0(a) + Maj(a, b, c)

    (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $r7) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w63)) (i32.load offset=32 (get_local $ptr))))
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

  
    
    ;; HASH COMPLETE FOR MESSAGE BLOCK
    ;; store hash values

    (i32.store offset=0  (get_local $ptr) (i32.add (get_local $r0) (i32.load offset=32 (get_local $ptr))))
    (i32.store offset=4  (get_local $ptr) (i32.add (get_local $r1) (i32.load offset=36 (get_local $ptr))))
    (i32.store offset=8  (get_local $ptr) (i32.add (get_local $r2) (i32.load offset=40 (get_local $ptr))))
    (i32.store offset=12 (get_local $ptr) (i32.add (get_local $r3) (i32.load offset=44 (get_local $ptr))))
    (i32.store offset=16 (get_local $ptr) (i32.add (get_local $r4) (i32.load offset=48 (get_local $ptr))))
    (i32.store offset=20 (get_local $ptr) (i32.add (get_local $r5) (i32.load offset=52 (get_local $ptr))))
    (i32.store offset=24 (get_local $ptr) (i32.add (get_local $r6) (i32.load offset=56 (get_local $ptr))))
    (i32.store offset=28 (get_local $ptr) (i32.add (get_local $r7) (i32.load offset=60 (get_local $ptr))))))
