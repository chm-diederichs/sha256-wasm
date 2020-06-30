(module
    (func $i32.log (import "debug" "log") (param i32))
    (func $i32.log_tee (import "debug" "log_tee") (param i32) (result i32))
    ;; No i64 interop with JS yet - but maybe coming with WebAssembly BigInt
    ;; So we can instead fake this by splitting the i64 into two i32 limbs,
    ;; however these are WASM functions using i32x2.log:
    (func $i32x2.log (import "debug" "log") (param i32) (param i32))
    (func $f32.log (import "debug" "log") (param f32))
    (func $f32.log_tee (import "debug" "log_tee") (param f32) (result f32))
    (func $f64.log (import "debug" "log") (param f64))
    (func $f64.log_tee (import "debug" "log_tee") (param f64) (result f64))
    
    (memory (export "memory") 10 65536)
    
    ;; i64 logging by splitting into two i32 limbs
    (func $i64.log
        (param $0 i64)
        (call $i32x2.log
            ;; Upper limb
            (i32.wrap/i64
                (i64.shr_u (get_local $0)
                    (i64.const 32)))
            ;; Lower limb
            (i32.wrap/i64 (get_local $0))))

    (func $i64.log_tee
        (param $0 i64)
        (result i64)
        (call $i64.log (get_local $0))
        (return (get_local $0)))

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
      (get_local $b)
      (i32.const 0x00FF00FF)
      (i32.and)
      (i32.rotr (i32.const 8))

      (get_local $b)
      (i32.const 0xFF00FF00)
      (i32.and)
      (i32.rotl (i32.const 8))))

    (func $round (param $w i32) (param $k i32)
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

      (set_local $ch_res (i32.xor (i32.and (get_global $e) (get_global $f)) (i32.and (i32.xor (get_global $e) (i32.const -1)) (get_global $g))))
      (set_local $maj_res (i32.xor (i32.xor (i32.and (get_global $a) (get_global $b)) (i32.and (get_global $a) (get_global $c))) (i32.and (get_global $b) (get_global $c))))
      
      (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_global $a) (i32.const 2)) (i32.rotr (get_global $a) (i32.const 13))) (i32.rotr (get_global $a) (i32.const 22))))
      (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_global $e) (i32.const 6)) (i32.rotr (get_global $e) (i32.const 11))) (i32.rotr (get_global $e) (i32.const 25))))

      (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_global $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w)) (get_local $k)))
      (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

      ;; update registers
      ;; h <- g
      ;; g <- f
      ;; f <- e
      ;; e <- d + T1
      ;; d <- c
      ;; c <- b
      ;; b <- a
      ;; a <- T1 + T2

      (set_global $h (get_global $g))
      (set_global $g (get_global $f))
      (set_global $f (get_global $e))
      (set_global $e (i32.add (get_global $d) (get_local $T1)))
      (set_global $d (get_global $c))
      (set_global $c (get_global $b))
      (set_global $b (get_global $a))
      (set_global $a (i32.add (get_local $T1) (get_local $T2))))

    (func $expand
      (param $a i32) (param $b i32) (param $c i32) (param $d i32)
      (result i32)

      (i32.add
        (i32.add
          (i32.add
            (i32.xor
              (i32.xor
                (i32.rotr (get_local $c) (i32.const 17))
                (i32.rotr (get_local $c) (i32.const 19)))
              (i32.shr_u (get_local $c) (i32.const 10)))
            (get_local $b))
          (i32.xor
            (i32.xor
              (i32.rotr (get_local $a) (i32.const 7))
              (i32.rotr (get_local $a) (i32.const 18)))
            (i32.shr_u (get_local $a) (i32.const 3)))
          (get_local $b))))

    (func $compress
      (param $ctx i32)

    (param $w0 i32) (param $w1 i32) (param $w2 i32) (param $w3 i32)
    (param $w4 i32) (param $w5 i32) (param $w6 i32) (param $w7 i32)
    (param $w8 i32) (param $w9 i32) (param $w10 i32) (param $w11 i32)
    (param $w12 i32) (param $w13 i32) (param $w14 i32) (param $w15 i32)
    
    ;; precomputed values
    (local $T1 i32)
    (local $T2 i32)

    (local $ch_res i32)
    (local $maj_res i32)
    (local $big_sig0_res i32)
    (local $big_sig1_res i32)

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

    (local $tmp0 i32)
    (local $tmp1 i32)
    (local $tmp2 i32)
    (local $tmp3 i32)
    (local $tmp4 i32)
    (local $tmp5 i32)
    (local $tmp6 i32)
    (local $tmp7 i32)
    (local $tmp8 i32)
    (local $tmp9 i32)
    (local $tmp10 i32)
    (local $tmp11 i32)
    (local $tmp12 i32)
    (local $tmp13 i32)
    (local $tmp14 i32)
    (local $tmp15 i32)

    ;;  store inital state
    (if (i32.eq (i32.load offset=104 (get_local $ctx)) (i32.const 0))
        (then
            (i32.store offset=0  (get_local $ctx) (i32.const 0x6a09e667))
            (i32.store offset=4  (get_local $ctx) (i32.const 0xbb67ae85))
            (i32.store offset=8  (get_local $ctx) (i32.const 0x3c6ef372))
            (i32.store offset=12 (get_local $ctx) (i32.const 0xa54ff53a))
            (i32.store offset=16 (get_local $ctx) (i32.const 0x510e527f))
            (i32.store offset=20 (get_local $ctx) (i32.const 0x9b05688c))
            (i32.store offset=24 (get_local $ctx) (i32.const 0x1f83d9ab))
            (i32.store offset=28 (get_local $ctx) (i32.const 0x5be0cd19))
            (i32.store offset=104 (get_local $ctx) (i32.const 1))))

    ;; load previous hash state into registers
    (set_global $a (i32.load offset=0  (get_local $ctx)))
    (set_global $b (i32.load offset=4  (get_local $ctx)))
    (set_global $c (i32.load offset=8  (get_local $ctx)))
    (set_global $d (i32.load offset=12 (get_local $ctx)))
    (set_global $e (i32.load offset=16 (get_local $ctx)))
    (set_global $f (i32.load offset=20 (get_local $ctx)))
    (set_global $g (i32.load offset=24 (get_local $ctx)))
    (set_global $h (i32.load offset=28 (get_local $ctx)))

    (set_local $w0  (call $i32.bswap (get_local $w0 )))
    (set_local $w1  (call $i32.bswap (get_local $w1 )))
    (set_local $w2  (call $i32.bswap (get_local $w2 )))
    (set_local $w3  (call $i32.bswap (get_local $w3 )))
    (set_local $w4  (call $i32.bswap (get_local $w4 )))
    (set_local $w5  (call $i32.bswap (get_local $w5 )))
    (set_local $w6  (call $i32.bswap (get_local $w6 )))
    (set_local $w7  (call $i32.bswap (get_local $w7 )))
    (set_local $w8  (call $i32.bswap (get_local $w8 )))
    (set_local $w9  (call $i32.bswap (get_local $w9 )))
    (set_local $w10 (call $i32.bswap (get_local $w10)))
    (set_local $w11 (call $i32.bswap (get_local $w11)))
    (set_local $w12 (call $i32.bswap (get_local $w12)))
    (set_local $w13 (call $i32.bswap (get_local $w13)))
    (set_local $w14 (call $i32.bswap (get_local $w14)))
    (set_local $w15 (call $i32.bswap (get_local $w15)))

    (set_local $w16 (call $expand (get_local $w14) (get_local $w9)  (get_local $w1)  (get_local $w0)))
    (set_local $w17 (call $expand (get_local $w15) (get_local $w10) (get_local $w2)  (get_local $w1)))
    (set_local $w18 (call $expand (get_local $w16) (get_local $w11) (get_local $w3)  (get_local $w2)))
    (set_local $w19 (call $expand (get_local $w17) (get_local $w12) (get_local $w4)  (get_local $w3)))
    (set_local $w20 (call $expand (get_local $w18) (get_local $w13) (get_local $w5)  (get_local $w4)))
    (set_local $w21 (call $expand (get_local $w19) (get_local $w14) (get_local $w6)  (get_local $w5)))
    (set_local $w22 (call $expand (get_local $w20) (get_local $w15) (get_local $w7)  (get_local $w6)))
    (set_local $w23 (call $expand (get_local $w21) (get_local $w16) (get_local $w8)  (get_local $w7)))
    (set_local $w24 (call $expand (get_local $w22) (get_local $w17) (get_local $w9)  (get_local $w8)))
    (set_local $w25 (call $expand (get_local $w23) (get_local $w18) (get_local $w10) (get_local $w9)))
    (set_local $w26 (call $expand (get_local $w24) (get_local $w19) (get_local $w11) (get_local $w10)))
    (set_local $w27 (call $expand (get_local $w25) (get_local $w20) (get_local $w12) (get_local $w11)))
    (set_local $w28 (call $expand (get_local $w26) (get_local $w21) (get_local $w13) (get_local $w12)))
    (set_local $w29 (call $expand (get_local $w27) (get_local $w22) (get_local $w14) (get_local $w13)))
    (set_local $w30 (call $expand (get_local $w28) (get_local $w23) (get_local $w15) (get_local $w14)))
    (set_local $w31 (call $expand (get_local $w29) (get_local $w24) (get_local $w16) (get_local $w15)))
    (set_local $w32 (call $expand (get_local $w30) (get_local $w25) (get_local $w17) (get_local $w16)))
    (set_local $w33 (call $expand (get_local $w31) (get_local $w26) (get_local $w18) (get_local $w17)))
    (set_local $w34 (call $expand (get_local $w32) (get_local $w27) (get_local $w19) (get_local $w18)))
    (set_local $w35 (call $expand (get_local $w33) (get_local $w28) (get_local $w20) (get_local $w19)))
    (set_local $w36 (call $expand (get_local $w34) (get_local $w29) (get_local $w21) (get_local $w20)))
    (set_local $w37 (call $expand (get_local $w35) (get_local $w30) (get_local $w22) (get_local $w21)))
    (set_local $w38 (call $expand (get_local $w36) (get_local $w31) (get_local $w23) (get_local $w22)))
    (set_local $w39 (call $expand (get_local $w37) (get_local $w32) (get_local $w24) (get_local $w23)))
    (set_local $w40 (call $expand (get_local $w38) (get_local $w33) (get_local $w25) (get_local $w24)))
    (set_local $w41 (call $expand (get_local $w39) (get_local $w34) (get_local $w26) (get_local $w25)))
    (set_local $w42 (call $expand (get_local $w40) (get_local $w35) (get_local $w27) (get_local $w26)))
    (set_local $w43 (call $expand (get_local $w41) (get_local $w36) (get_local $w28) (get_local $w27)))
    (set_local $w44 (call $expand (get_local $w42) (get_local $w37) (get_local $w29) (get_local $w28)))
    (set_local $w45 (call $expand (get_local $w43) (get_local $w38) (get_local $w30) (get_local $w29)))
    (set_local $w46 (call $expand (get_local $w44) (get_local $w39) (get_local $w31) (get_local $w30)))
    (set_local $w47 (call $expand (get_local $w45) (get_local $w40) (get_local $w32) (get_local $w31)))
    (set_local $w48 (call $expand (get_local $w46) (get_local $w41) (get_local $w33) (get_local $w32)))
    (set_local $w49 (call $expand (get_local $w47) (get_local $w42) (get_local $w34) (get_local $w33)))
    (set_local $w50 (call $expand (get_local $w48) (get_local $w43) (get_local $w35) (get_local $w34)))
    (set_local $w51 (call $expand (get_local $w49) (get_local $w44) (get_local $w36) (get_local $w35)))
    (set_local $w52 (call $expand (get_local $w50) (get_local $w45) (get_local $w37) (get_local $w36)))
    (set_local $w53 (call $expand (get_local $w51) (get_local $w46) (get_local $w38) (get_local $w37)))
    (set_local $w54 (call $expand (get_local $w52) (get_local $w47) (get_local $w39) (get_local $w38)))
    (set_local $w55 (call $expand (get_local $w53) (get_local $w48) (get_local $w40) (get_local $w39)))
    (set_local $w56 (call $expand (get_local $w54) (get_local $w49) (get_local $w41) (get_local $w40)))
    (set_local $w57 (call $expand (get_local $w55) (get_local $w50) (get_local $w42) (get_local $w41)))
    (set_local $w58 (call $expand (get_local $w56) (get_local $w51) (get_local $w43) (get_local $w42)))
    (set_local $w59 (call $expand (get_local $w57) (get_local $w52) (get_local $w44) (get_local $w43)))
    (set_local $w60 (call $expand (get_local $w58) (get_local $w53) (get_local $w45) (get_local $w44)))
    (set_local $w61 (call $expand (get_local $w59) (get_local $w54) (get_local $w46) (get_local $w45)))
    (set_local $w62 (call $expand (get_local $w60) (get_local $w55) (get_local $w47) (get_local $w46)))
    (set_local $w63 (call $expand (get_local $w61) (get_local $w56) (get_local $w48) (get_local $w47)))
    
    (call $round (get_local $w0)  (i32.const 0x428a2f98))
    (call $round (get_local $w1)  (i32.const 0x71374491))
    (call $round (get_local $w2)  (i32.const 0xb5c0fbcf))
    (call $round (get_local $w3)  (i32.const 0xe9b5dba5))
    (call $round (get_local $w4)  (i32.const 0x3956c25b))
    (call $round (get_local $w5)  (i32.const 0x59f111f1))
    (call $round (get_local $w6)  (i32.const 0x923f82a4))
    (call $round (get_local $w7)  (i32.const 0xab1c5ed5))
    (call $round (get_local $w8)  (i32.const 0xd807aa98))
    (call $round (get_local $w9)  (i32.const 0x12835b01))
    (call $round (get_local $w10) (i32.const 0x243185be))
    (call $round (get_local $w11) (i32.const 0x550c7dc3))
    (call $round (get_local $w12) (i32.const 0x72be5d74))
    (call $round (get_local $w13) (i32.const 0x80deb1fe))
    (call $round (get_local $w14) (i32.const 0x9bdc06a7))
    (call $round (get_local $w15) (i32.const 0xc19bf174))
    (call $round (get_local $w16) (i32.const 0xe49b69c1))
    (call $round (get_local $w17) (i32.const 0xefbe4786))
    (call $round (get_local $w18) (i32.const 0x0fc19dc6))
    (call $round (get_local $w19) (i32.const 0x240ca1cc))
    (call $round (get_local $w20) (i32.const 0x2de92c6f))
    (call $round (get_local $w21) (i32.const 0x4a7484aa))
    (call $round (get_local $w22) (i32.const 0x5cb0a9dc))
    (call $round (get_local $w23) (i32.const 0x76f988da))
    (call $round (get_local $w24) (i32.const 0x983e5152))
    (call $round (get_local $w25) (i32.const 0xa831c66d))
    (call $round (get_local $w26) (i32.const 0xb00327c8))
    (call $round (get_local $w27) (i32.const 0xbf597fc7))
    (call $round (get_local $w28) (i32.const 0xc6e00bf3))
    (call $round (get_local $w29) (i32.const 0xd5a79147))
    (call $round (get_local $w30) (i32.const 0x06ca6351))
    (call $round (get_local $w31) (i32.const 0x14292967))
    (call $round (get_local $w32) (i32.const 0x27b70a85))
    (call $round (get_local $w33) (i32.const 0x2e1b2138))
    (call $round (get_local $w34) (i32.const 0x4d2c6dfc))
    (call $round (get_local $w35) (i32.const 0x53380d13))
    (call $round (get_local $w36) (i32.const 0x650a7354))
    (call $round (get_local $w37) (i32.const 0x766a0abb))
    (call $round (get_local $w38) (i32.const 0x81c2c92e))
    (call $round (get_local $w39) (i32.const 0x92722c85))
    (call $round (get_local $w40) (i32.const 0xa2bfe8a1))
    (call $round (get_local $w41) (i32.const 0xa81a664b))
    (call $round (get_local $w42) (i32.const 0xc24b8b70))
    (call $round (get_local $w43) (i32.const 0xc76c51a3))
    (call $round (get_local $w44) (i32.const 0xd192e819))
    (call $round (get_local $w45) (i32.const 0xd6990624))
    (call $round (get_local $w46) (i32.const 0xf40e3585))
    (call $round (get_local $w47) (i32.const 0x106aa070))
    (call $round (get_local $w48) (i32.const 0x19a4c116))
    (call $round (get_local $w49) (i32.const 0x1e376c08))
    (call $round (get_local $w50) (i32.const 0x2748774c))
    (call $round (get_local $w51) (i32.const 0x34b0bcb5))
    (call $round (get_local $w52) (i32.const 0x391c0cb3))
    (call $round (get_local $w53) (i32.const 0x4ed8aa4a))
    (call $round (get_local $w54) (i32.const 0x5b9cca4f))
    (call $round (get_local $w55) (i32.const 0x682e6ff3))
    (call $round (get_local $w56) (i32.const 0x748f82ee))
    (call $round (get_local $w57) (i32.const 0x78a5636f))
    (call $round (get_local $w58) (i32.const 0x84c87814))
    (call $round (get_local $w59) (i32.const 0x8cc70208))
    (call $round (get_local $w60) (i32.const 0x90befffa))
    (call $round (get_local $w61) (i32.const 0xa4506ceb))
    (call $round (get_local $w62) (i32.const 0xbef9a3f7))
    (call $round (get_local $w63) (i32.const 0xc67178f2))

    ;; store hash values
    (i32.store offset=0  (get_local $ctx) (i32.add (i32.load offset=0  (get_local $ctx)) (get_global $a)))
    (i32.store offset=4  (get_local $ctx) (i32.add (i32.load offset=8  (get_local $ctx)) (get_global $b)))
    (i32.store offset=8 (get_local $ctx) (i32.add (i32.load offset=16 (get_local $ctx)) (get_global $c)))
    (i32.store offset=12 (get_local $ctx) (i32.add (i32.load offset=24 (get_local $ctx)) (get_global $d)))
    (i32.store offset=16 (get_local $ctx) (i32.add (i32.load offset=32 (get_local $ctx)) (get_global $e)))
    (i32.store offset=20 (get_local $ctx) (i32.add (i32.load offset=40 (get_local $ctx)) (get_global $f)))
    (i32.store offset=24 (get_local $ctx) (i32.add (i32.load offset=48 (get_local $ctx)) (get_global $g)))
    (i32.store offset=28 (get_local $ctx) (i32.add (i32.load offset=56 (get_local $ctx)) (get_global $h))))
        
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

        (set_local $bytes_read (i64.load offset=32 (get_local $ctx)))
        (set_local $tail (i32.add (i32.and (i32.wrap/i64 (get_local $bytes_read)) (i32.const 0x3f)) (get_local $length)))

        ;; load current block position
        (set_local $bytes_read (i64.add (get_local $bytes_read) (i64.extend_u/i32 (get_local $length))))
        (i64.store offset=32 (get_local $ctx) (get_local $bytes_read))

        (block $finish
          (set_local $w0  (i32.load offset=36 (get_local $ctx)))
          (set_local $w1  (i32.load offset=40 (get_local $ctx)))
          (set_local $w2  (i32.load offset=44 (get_local $ctx)))
          (set_local $w3  (i32.load offset=48 (get_local $ctx)))
          (set_local $w4  (i32.load offset=52 (get_local $ctx)))
          (set_local $w5  (i32.load offset=56 (get_local $ctx)))
          (set_local $w6  (i32.load offset=60 (get_local $ctx)))
          (set_local $w7  (i32.load offset=64 (get_local $ctx)))
          (set_local $w8  (i32.load offset=68 (get_local $ctx)))
          (set_local $w9  (i32.load offset=72 (get_local $ctx)))
          (set_local $w10 (i32.load offset=76 (get_local $ctx)))
          (set_local $w11 (i32.load offset=80 (get_local $ctx)))
          (set_local $w12 (i32.load offset=84 (get_local $ctx)))
          (set_local $w13 (i32.load offset=88 (get_local $ctx)))
          (set_local $w14 (i32.load offset=92 (get_local $ctx)))
          (set_local $w15 (i32.load offset=96 (get_local $ctx)))

          (tee_local $tail (i32.sub (get_local $tail) (i32.const 64)))
          (i32.const 0)
          (i32.lt_s)
          (br_if $finish)

          (get_local $ctx)
          (get_local $w0 )
          (get_local $w1 )
          (get_local $w2 )
          (get_local $w3 )
          (get_local $w4 )
          (get_local $w5 )
          (get_local $w6 )
          (get_local $w7 )
          (get_local $w8 )
          (get_local $w9 )
          (get_local $w10)
          (get_local $w11)
          (get_local $w12)
          (get_local $w13)
          (get_local $w14)
          (get_local $w15)
          (call $compress)

          (loop $rest_of_input
            (set_local $w0  (i32.load offset=0  (get_local $roi)))
            (set_local $w1  (i32.load offset=4  (get_local $roi)))
            (set_local $w2  (i32.load offset=8  (get_local $roi)))
            (set_local $w3  (i32.load offset=12 (get_local $roi)))
            (set_local $w4  (i32.load offset=16 (get_local $roi)))
            (set_local $w5  (i32.load offset=20 (get_local $roi)))
            (set_local $w6  (i32.load offset=24 (get_local $roi)))
            (set_local $w7  (i32.load offset=28 (get_local $roi)))
            (set_local $w8  (i32.load offset=32 (get_local $roi)))
            (set_local $w9  (i32.load offset=36 (get_local $roi)))
            (set_local $w10 (i32.load offset=40 (get_local $roi)))
            (set_local $w11 (i32.load offset=44 (get_local $roi)))
            (set_local $w12 (i32.load offset=48 (get_local $roi)))
            (set_local $w13 (i32.load offset=52 (get_local $roi)))
            (set_local $w14 (i32.load offset=56 (get_local $roi)))
            (set_local $w15 (i32.load offset=60 (get_local $roi)))

            (set_local $roi (i32.add (get_local $roi) (i32.const 64)))

            (tee_local $tail (i32.sub (get_local $tail) (i32.const 64)))
            (i32.const 0)
            (i32.lt_s)
            (if
              (then
                (i32.store offset=40 (get_local $ctx) (get_local $w0))
                (i32.store offset=44 (get_local $ctx) (get_local $w1))
                (i32.store offset=48 (get_local $ctx) (get_local $w2))
                (i32.store offset=52 (get_local $ctx) (get_local $w3))
                (i32.store offset=56 (get_local $ctx) (get_local $w4))
                (i32.store offset=60 (get_local $ctx) (get_local $w5))
                (i32.store offset=64 (get_local $ctx) (get_local $w6))
                (i32.store offset=68 (get_local $ctx) (get_local $w7))
                (i32.store offset=72 (get_local $ctx) (get_local $w8))
                (i32.store offset=76 (get_local $ctx) (get_local $w9))
                (i32.store offset=80 (get_local $ctx) (get_local $w10))
                (i32.store offset=84 (get_local $ctx) (get_local $w11))
                (i32.store offset=88 (get_local $ctx) (get_local $w12))
                (i32.store offset=92 (get_local $ctx) (get_local $w13))
                (i32.store offset=96 (get_local $ctx) (get_local $w14))
                (i32.store offset=100 (get_local $ctx) (get_local $w15))
                (br $finish)))

            (get_local $ctx)
            (get_local $w0 )
            (get_local $w1 )
            (get_local $w2 )
            (get_local $w3 )
            (get_local $w4 )
            (get_local $w5 )
            (get_local $w6 )
            (get_local $w7 )
            (get_local $w8 )
            (get_local $w9 )
            (get_local $w10)
            (get_local $w11)
            (get_local $w12)
            (get_local $w13)
            (get_local $w14)
            (get_local $w15)
            (call $compress)

            (br $rest_of_input)))

        (if (i32.eq (get_local $final) (i32.const 1))
          (then
            (set_local $tail (i32.and (i32.wrap/i64 (get_local $bytes_read)) (i32.const 0x3f)))
            (set_local $last_word (i32.shl (i32.const 0x80) (i32.shl (i32.and (get_local $tail) (i32.const 0x3)) (i32.const 3))))

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
                                                                                        (get_local $tail)
                                                                                        (i32.const 3)
                                                                                        (i32.shr_u)
                                                                                        (br_table $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15)))
                                                                                    
                                                                                    (get_local $last_word)
                                                                                    (get_local $w14)
                                                                                    (i32.or)
                                                                                    (set_local $w14)
                                                                                    (set_local $last_word (i32.const 0)))
                                                                                
                                                                                (get_local $last_word)
                                                                                (get_local $w15)
                                                                                (i32.or)
                                                                                (set_local $w15)
                                                                                (set_local $last_word (i32.const 0))

                                                                                ;; compress
                                                                                (get_local $ctx)
                                                                                (get_local $w0)
                                                                                (get_local $w1)
                                                                                (get_local $w2)
                                                                                (get_local $w3)
                                                                                (get_local $w4)
                                                                                (get_local $w5)
                                                                                (get_local $w6)
                                                                                (get_local $w7)
                                                                                (get_local $w8)
                                                                                (get_local $w9)
                                                                                (get_local $w10)
                                                                                (get_local $w11)
                                                                                (get_local $w12)
                                                                                (get_local $w13)
                                                                                (get_local $w14)
                                                                                (get_local $w15)
                                                                                (call $compress)

                                                                                (i64.store offset=32 (get_local $ctx) (get_local $bytes_read))

                                                                                ;; zero out words
                                                                                (set_local $w0  (i32.const 0))
                                                                                (set_local $w1  (i32.const 0))
                                                                                (set_local $w2  (i32.const 0))
                                                                                (set_local $w3  (i32.const 0))
                                                                                (set_local $w4  (i32.const 0))
                                                                                (set_local $w5  (i32.const 0))
                                                                                (set_local $w6  (i32.const 0))
                                                                                (set_local $w7  (i32.const 0))
                                                                                (set_local $w8  (i32.const 0))
                                                                                (set_local $w9  (i32.const 0))
                                                                                (set_local $w10 (i32.const 0))
                                                                                (set_local $w11 (i32.const 0))
                                                                                (set_local $w12 (i32.const 0))
                                                                                (set_local $w13 (i32.const 0))
                                                                                (set_local $w14 (i32.const 0))
                                                                                (set_local $w15 (i32.const 0)))
                                                                            
                                                                            (get_local $last_word)
                                                                            (get_local $w0)
                                                                            (i32.or)
                                                                            (set_local $w0)
                                                                            (set_local $last_word (i32.const 0)))
                                                                        
                                                                        (get_local $last_word)
                                                                        (get_local $w1)
                                                                        (i32.or)
                                                                        (set_local $w1)
                                                                        (set_local $last_word (i32.const 0)))
                                                                    
                                                                    (get_local $last_word)
                                                                    (get_local $w2)
                                                                    (i32.or)
                                                                    (set_local $w2)
                                                                    (set_local $last_word (i32.const 0)))
                                                                
                                                                (get_local $last_word)
                                                                (get_local $w3)
                                                                (i32.or)
                                                                (set_local $w3)
                                                                (set_local $last_word (i32.const 0)))
                                                            
                                                            (get_local $last_word)
                                                            (get_local $w4)
                                                            (i32.or)
                                                            (set_local $w4)
                                                            (set_local $last_word (i32.const 0)))
                                                        
                                                        (get_local $last_word)
                                                        (get_local $w5)
                                                        (i32.or)
                                                        (set_local $w5)
                                                        (set_local $last_word (i32.const 0)))
                                                    
                                                    (get_local $last_word)
                                                    (get_local $w6)
                                                    (i32.or)
                                                    (set_local $w6)
                                                    (set_local $last_word (i32.const 0)))
                                                
                                                (get_local $last_word)
                                                (get_local $w7)
                                                (i32.or)
                                                (set_local $w7)
                                                (set_local $last_word (i32.const 0)))
                                            
                                            (get_local $last_word)
                                            (get_local $w8)
                                            (i32.or)
                                            (set_local $w8)
                                            (set_local $last_word (i32.const 0)))
                                        
                                        (get_local $last_word)
                                        (get_local $w9)
                                        (i32.or)
                                        (set_local $w9)
                                        (set_local $last_word (i32.const 0)))
                                    
                                    (get_local $last_word)
                                    (get_local $w10)
                                    (i32.or)
                                    (set_local $w10)
                                    (set_local $last_word (i32.const 0)))
                                
                                (get_local $last_word)
                                (get_local $w11)
                                (i32.or)
                                (set_local $w11)
                                (set_local $last_word (i32.const 0)))
                            
                            (get_local $last_word)
                            (get_local $w12)
                            (i32.or)
                            (set_local $w12)
                            (set_local $last_word (i32.const 0)))
                        
                        (get_local $last_word)
                        (get_local $w13)
                        (i32.or)
                        (set_local $w13)
                        (set_local $last_word (i32.const 0)))
                
                (set_local $w14 (i32.wrap/i64 (i64.shr_u (get_local $bytes_read) (i64.const 29))))
                (set_local $w15 (i32.wrap/i64 (i64.shl (get_local $bytes_read) (i64.const 3))))

                (get_local $ctx)
                (get_local $w0)
                (get_local $w1)
                (get_local $w2)
                (get_local $w3)
                (get_local $w4)
                (get_local $w5)
                (get_local $w6)
                (get_local $w7)
                (get_local $w8)
                (get_local $w9)
                (get_local $w10)
                (get_local $w11)
                (get_local $w12)
                (get_local $w13)
                (get_local $w14)
                (get_local $w15)
                (call $compress)

                (get_local $ctx)
                (i32.load offset=0 (get_local $ctx))
                (call $i32.bswap)
                (i32.store offset=0)

                (get_local $ctx)
                (i32.load offset=4 (get_local $ctx))
                (call $i32.bswap)
                (i32.store offset=4)

                (get_local $ctx)
                (i32.load offset=8 (get_local $ctx))
                (call $i32.bswap)
                (i32.store offset=8)

                (get_local $ctx)
                (i32.load offset=12 (get_local $ctx))
                (call $i32.bswap)
                (i32.store offset=12)

                (get_local $ctx)
                (i32.load offset=16 (get_local $ctx))
                (call $i32.bswap)
                (i32.store offset=16)

                (get_local $ctx)
                (i32.load offset=20 (get_local $ctx))
                (call $i32.bswap)
                (i32.store offset=20)

                (get_local $ctx)
                (i32.load offset=24 (get_local $ctx))
                (call $i32.bswap)
                (i32.store offset=24)

                (get_local $ctx)
                (i32.load offset=28 (get_local $ctx))
                (call $i32.bswap)
                (i32.store offset=28)))))
