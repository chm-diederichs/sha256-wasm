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

  (memory (export "memory") 10 1000)

  ;; i64 logging by splitting into two i32 limbs
  (func $i64.log
    (param $0 i64)
    (call $i32x2.log
      ;; Upper limb
      (i32.wrap/i64
        (i64.shl (get_local $0)
                 (i64.const 32)))
      ;; Lower limb
      (i32.wrap/i64 (get_local $0))))

  (func $i64.log_tee
    (param $0 i64)
    (result i64)
    (call $i64.log (get_local $0))
    (return (get_local $0)))
    
  (func (export "sha256_init") (param $ptr i32) ;; (param $outlen i32)
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
    (i32.store offset=284 (get_local $ptr) (i32.xor (i32.const 0xc67178f2) (i32.const 0)))

    ;; setup array for input data 288-352
    (i32.store offset=288 (get_local $ptr) (i32.const 0))
    (i32.store offset=292 (get_local $ptr) (i32.const 0))
    (i32.store offset=296 (get_local $ptr) (i32.const 0))
    (i32.store offset=300 (get_local $ptr) (i32.const 0))
    (i32.store offset=304 (get_local $ptr) (i32.const 0))
    (i32.store offset=308 (get_local $ptr) (i32.const 0))
    (i32.store offset=312 (get_local $ptr) (i32.const 0))
    (i32.store offset=316 (get_local $ptr) (i32.const 0))
    (i32.store offset=320 (get_local $ptr) (i32.const 0))
    (i32.store offset=324 (get_local $ptr) (i32.const 0))
    (i32.store offset=328 (get_local $ptr) (i32.const 0))
    (i32.store offset=332 (get_local $ptr) (i32.const 0))
    (i32.store offset=336 (get_local $ptr) (i32.const 0))
    (i32.store offset=340 (get_local $ptr) (i32.const 0))
    (i32.store offset=344 (get_local $ptr) (i32.const 0))
    (i32.store offset=348 (get_local $ptr) (i32.const 0))

    ;; keep track of input start byte 352
    (i32.store offset=352 (get_local $ptr) (i32.const 0xffffffff))
    
    ;; keep track of input end byte 356
    (i32.store offset=356 (get_local $ptr) (i32.const 0)))


  ;; Define bit-mixing functions
    ;;  S_n -> right rotation by n bits
    ;;  R_n -> right shift by n bits

  ;; Ch(x, y, z) = (x & y) ^ (~x & z)
  (func $Ch (param $x i32) (param $y i32) (param $z i32)
    (result i32)
    ;; (call $i32.log (get_local $x))
    ;; (call $i32.log (get_local $y))
    ;; (call $i32.log (get_local $z))

    (i32.xor
      (i32.and (get_local $x) (get_local $y))             
      (i32.and 
        (i32.xor (get_local $x) (i32.const -1))
        (get_local $z))))

  ;; Maj(x, y, z) = (x & y) ^ (y & z) ^ (z & x)
  (func $Maj (param $x i32) (param $y i32) (param $z i32)
    (result i32)
    ;; (call $i32.log (get_local $x))
    ;; (call $i32.log (get_local $y))
    ;; (call $i32.log (get_local $z))

    (i32.xor
      (i32.xor
        (i32.and (get_local $x) (get_local $y))
        (i32.and (get_local $x) (get_local $z)))
      (i32.and (get_local $y) (get_local $z))))

  ;;  big_sig0(x) = S_2(x) ^ S_13(x) ^ S_22(x)
  (func $big_sig0 (param $x i32)
    (result i32)
    ;; (call $i32.log (get_local $x))

    (i32.xor
      (i32.xor
        (i32.rotr (get_local $x) (i32.const 2))
        (i32.rotr (get_local $x) (i32.const 13)))
      (i32.rotr (get_local $x) (i32.const 22))))

  ;;  big_sig1(x) = S_6(x) ^ S_11(x) ^ S_25(x)
  (func $big_sig1 (param $x i32)
    (result i32)
    ;; (call $i32.log (get_local $x))

    (i32.xor
      (i32.xor
        (i32.rotr (get_local $x) (i32.const 6))
        (i32.rotr (get_local $x) (i32.const 11)))
      (i32.rotr (get_local $x) (i32.const 25))))

  ;;  sig0(x) = S_7(x) ^ S_18(x) ^ R_3(x)
  (func $sig0 (param $x i32)
    (result i32)

    (i32.xor
      (i32.xor
        (i32.rotr (get_local $x) (i32.const 7))
        (i32.rotr (get_local $x) (i32.const 18)))
      (i32.shr_u (get_local $x) (i32.const 3))))

  ;;  sig0(x) = S_17(x) ^ S_19(x) ^ R_10(x)
  (func $sig1 (param $x i32)
    (result i32)

    (i32.xor
      (i32.xor
        (i32.rotr (get_local $x) (i32.const 17))
        (i32.rotr (get_local $x) (i32.const 19)))
      (i32.shr_u (get_local $x) (i32.const 10))))

  ;; (func $sha256_update (export "sha256_compress") (param $ctx i32) (param $input i32) (param $input_end i32)
  ;;   (local $i i32)
  ;;   (local $t i32)
  ;;   (local $c i32)

  ;;   (set_local $t (i32.load (i32.add (get_local $ctx) (i32.const 32))))
  ;;   (set_local $c (i32.load (i32.add (get_local $ctx) (i32.const 36)))) 
  ;;   (set_local $i (i32.add (get_local $ctx) (i32.const 0)))

  ;;   (block $end
  ;;     (loop $start
  ;;       ;; if end of input is reached, break from function
  ;;       (br_if $end (i32.eq (get_local $i) (get_local $input_end)))

  ;;       ;; if 64 bytes have been read, hash them into state
  ;;       (if (i32.eq (get_local $i) (i32.const 64))
  ;;           (then
  ;;               (i32.store (get_local $t) (i32.add (i32.load (get_local $t)) (get_local $i)))
  ;;               (set_local $i (i32.const 0))

  ;;               (call $sha256_compress (get_local $ctx))
  ;;           )
  ;;       )

  ;;       ;; else load byte and increment pointers
  ;;       (i32.store8 (i32.add (get_local $ctx) (get_local $i)) (i32.load8_u (get_local $input)))
  ;;       (set_local $i (i32.add (get_local $i) (i32.const 1)))
  ;;       (set_local $input (i32.add (get_local $input) (i32.const 1)))

  ;;       (br $start)
  ;;     )
  ;;   )

  ;;   (i32.store (get_local $c) (get_local $i))
  ;; )
    (func $sha256_update (export "sha256_update") (param $ctx i32) (param $input i32) (param $input_end i32)
        (local $i i32)
        (local $input_length i64)
        (local $block_end i32)

        ;; only store input start for the first input
        (if (i32.eq (i32.load offset=64 (get_local $ctx)) (i32.const 0xffffffff))
            (then (i32.store offset=64 (get_local $ctx) (get_local $input)))
        )

        (i32.store offset=68 (get_local $ctx) (get_local $input_end))

        ;; (i32.store (get_local $input_end) (i32.wrap/i64 (i64.shr_u (get_local $input_length) (i64.const 32))))
        ;; (i32.store offset=4 (get_local $input_end) (i32.wrap/i64 (get_local $input_length)))
        ;; (set_local $input_end (i32.add (get_local $input_end) (i32.const 8)))
        ;; (call $i32.log (i32.load (i32.sub (get_local $input_end) (i32.const 4))))
        ;; (call $i32.log (get_local $input))
        ;; (call $i64.log (get_local $input_length))

        
        (set_local $i (i32.const 3))
        (set_local $block_end (i32.const 67))

        (block $end
            (loop $start
                (br_if $end (i32.eq (get_local $input) (get_local $input_end)))
                
                (if (i32.eq (get_local $i) (get_local $block_end))
                    (then
                        (set_local $block_end (i32.add (get_local $block_end) (i32.const 64)))
                        (call $sha256_compress (get_local $ctx))
                        (call $i64.log (i64.const 0))
                        (br $start)
                    )
                )

            
                ;; (call $i32.log (i32.add (get_local $ctx) (get_local $i)))
                (call $i32.log (get_local $i))
                ;; (call $i32.log (i32.load8_u (get_local $input)))
                (i32.store8 (i32.add (get_local $ctx) (i32.rem_u (get_local $i) (i32.const 64))) (i32.load8_u (get_local $input)))
                ;; (call $i32.log (i32.load8_u (i32.add (get_local $ctx) (get_local $i))))
                ;; (call $i32.log (i32.load8_u (i32.add (get_local $ctx) (get_local $i))))

                (call $i32.log (i32.load8_u (i32.add (get_local $ctx) (get_local $i))))
                (set_local $i (i32.sub (get_local $i) (i32.const 1)))
                (set_local $input (i32.add (get_local $input) (i32.const 1)))

                ;; int32.load expects little endian, increment by 4 then successively decrement by 1 to load each 4 bytes of input
                (if (i32.eq (i32.rem_u (get_local $i) (i32.const 4)) (i32.const 3))
                    (then
                        (set_local $i (i32.add (get_local $i) (i32.const 8)))
                    )
                )

                (br $start)
            )   
        )

        ;; pad with 0b10000000 === 0x80
        ;; (call $i32.log (i32.add (get_local $ctx) (get_local $i)))
        ;; (call $i32.log (i32.rem_u (get_local $i) (i32.const 4)))
        ;; (call $i32.log (i32.sub (i32.add (get_local $ctx) (get_local $i)) (i32.rem_u (get_local $i) (i32.const 4))))

        ;; ;; endian converter
        ;; (block $length_end
        ;;     (loop $length
        ;;         (br_if $length_end (i32.eq (get_local $ctr) (i32.const 8)))
        ;;         (call $i32.log (get_local $ctx))
        ;;         (call $i32.log (i32.add (i32.add (get_local $ctx) (get_local $i) (i32.sub (i32.const 8) (get_local $ctr)))))
        ;;         (call $i64.log (i64.shr_u (get_local $input_length) (i64.extend_u/i32 (i32.mul (get_local $ctr) (i32.const 8)))))

        ;;         (i64.store8 (i32.add (i32.add (get_local $ctx) (get_local $i)) (i32.sub (i32.const 7) (get_local $ctr)))
        ;;                     (i64.shr_u (get_local $input_length) (i64.extend_u/i32 (i32.mul (get_local $ctr) (i32.const 8)))))

        ;;         (set_local $ctr (i32.add (get_local $ctr) (i32.const 1)))

        ;;         (call $i32.log (i32.load8_u (i32.add (i32.add (get_local $ctx) (get_local $i)) (i32.sub (i32.const 8) (get_local $ctr)))))
        ;;         (br $length)
        ;;     )
        ;; )
    )

    (func $sha256_pad (export "sha256_pad") (param $mem i32) (param $ctx i32)
        (local $input_length i64)
        (local $input_end i32)
        (local $input_start i32)
        (local $input i32)

        (set_local $input_start (i32.load offset=352 (get_local $mem)))
        (set_local $input_end (i32.load offset=356 (get_local $mem)))

        (call $i32.log (get_local $input_start))

        (set_local $input (get_local $input_start))
        (set_local $input_length 
            (i64.extend_u/i32 
                (i32.mul 
                    (i32.sub (get_local $input_end) (get_local $input)) 
                    (i32.const 8))))

        (i32.store8 (get_local $input_end) (i32.const 0x80))
        (set_local $input_end (i32.add (get_local $input_end) (i32.const 1)))
        ;; (set_local $i (i32.wrap/i64 (get_local $input_length)))

        (block $pad_end
            (loop $pad
                (br_if $pad_end (i32.eq (i32.rem_u (i32.sub (get_local $input_end) (get_local $input)) (i32.const 64)) (i32.const 56)))
                (set_local $input_end (i32.add (get_local $input_end) (i32.const 1)))

                (i32.store8 (get_local $input_end) (i32.const 0))
                (br $pad)
            )
        )

        ;; (call $i64.log (i64.shr_u (get_local $input_length) (i64.const 56)))
        ;; (call $i64.log (i64.shr_u (get_local $input_length) (i64.const 48)))
        ;; (call $i64.log (i64.shr_u (get_local $input_length) (i64.const 40)))
        ;; (call $i64.log (i64.shr_u (get_local $input_length) (i64.const 32)))
        ;; (call $i64.log (i64.shr_u (get_local $input_length) (i64.const 24)))
        ;; (call $i64.log (i64.shr_u (get_local $input_length) (i64.const 16)))
        ;; (call $i64.log (i64.shr_u (get_local $input_length) (i64.const 8)))

        ;; (call $i64.log (get_local $input_length))

        (i64.store8 offset=0 (get_local $input_end) (i64.shr_u (get_local $input_length) (i64.const 56)))
        (i64.store8 offset=1 (get_local $input_end) (i64.shr_u (get_local $input_length) (i64.const 48)))
        (i64.store8 offset=2 (get_local $input_end) (i64.shr_u (get_local $input_length) (i64.const 40)))
        (i64.store8 offset=3 (get_local $input_end) (i64.shr_u (get_local $input_length) (i64.const 32)))
        (i64.store8 offset=4 (get_local $input_end) (i64.shr_u (get_local $input_length) (i64.const 24)))
        (i64.store8 offset=5 (get_local $input_end) (i64.shr_u (get_local $input_length) (i64.const 16)))
        (i64.store8 offset=6 (get_local $input_end) (i64.shr_u (get_local $input_length) (i64.const 8)))
        (i64.store8 offset=7 (get_local $input_end) (get_local $input_length))

        (set_local $input_end (i32.add (get_local $input_end) (i32.const 8)))
        ;; (call $i32.log (i32.add (i32.const 288) (i32.sub (get_local $input_start) (i32.const 636))))
        ;; (call $i32.log (i32.load8_u (i32.add (i32.const 288) (i32.sub (get_local $input_start) (i32.const 634)))))
        ;; (call $i32.log (i32.load8_u (i32.add (i32.const 288) (i32.sub (get_local $input_start) (i32.const 635)))))
        ;; (call $i32.log (i32.load8_u (i32.add (i32.const 288) (i32.sub (get_local $input_start) (i32.const 636)))))
        ;; (call $i32.log (i32.load8_u (i32.add (i32.const 288) (i32.sub (get_local $input_start) (i32.const 637)))))
        ;; (call $i32.log (i32.load8_u (i32.add (i32.const 288) (i32.sub (get_local $input_start) (i32.const 638)))))

        (call $sha256_update (i32.const 288) (get_local $input_start) (get_local $input_end))
    )

                                                
    (func $sha256_compress (export "sha256_compress") (param $mem i32)
        (local $h1 i32)
        (local $h2 i32)
        (local $h3 i32)
        (local $h4 i32)
        (local $h5 i32)
        (local $h6 i32)
        (local $h7 i32)
        (local $h8 i32)


        ;; registers
        (local $a i32)
        (local $b i32)
        (local $c i32)
        (local $d i32)
        (local $e i32)
        (local $f i32)
        (local $g i32)
        (local $h i32)

        ;; precomputed values
        (local $T1 i32)
        (local $T2 i32)

        (local $ch_res i32)
        (local $maj_res i32)
        (local $big_sig0_res i32)
        (local $big_sig1_res i32)
    ;; 380
        ;; expanded message schedule
        (local $w0 i32)  (local $w1 i32)  (local $w2 i32)  (local $w3 i32)  
        (local $w4 i32)  (local $w5 i32)  (local $w6 i32)  (local $w7 i32) 
        (local $w8 i32)  (local $w9 i32)  (local $w10 i32) (local $w11 i32) 
        (local $w12 i32) (local $w13 i32) (local $w14 i32) (local $w15 i32)
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
    ;; 636
        ;; message loaded
        (set_local $w0 (i32.load (get_local $mem)))
        (set_local $w1 (i32.load offset=4 (get_local $mem)))
        (set_local $w2 (i32.load offset=8 (get_local $mem)))
        (set_local $w3 (i32.load offset=12 (get_local $mem)))
        (set_local $w4 (i32.load offset=16 (get_local $mem)))
        (set_local $w5 (i32.load offset=20 (get_local $mem)))
        (set_local $w6 (i32.load offset=24 (get_local $mem)))
        (set_local $w7 (i32.load offset=28 (get_local $mem)))
        (set_local $w8 (i32.load offset=32 (get_local $mem)))
        (set_local $w9 (i32.load offset=36 (get_local $mem)))
        (set_local $w10 (i32.load offset=40 (get_local $mem)))
        (set_local $w11 (i32.load offset=44 (get_local $mem)))
        (set_local $w12 (i32.load offset=48 (get_local $mem)))
        (set_local $w13 (i32.load offset=52 (get_local $mem)))
        (set_local $w14 (i32.load offset=56 (get_local $mem)))
        (set_local $w15 (i32.load offset=60 (get_local $mem)))
        
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

        ;; load previous hash state
        (set_local $a (i32.load offset=0 (i32.const 0)))
        (set_local $b (i32.load offset=4 (i32.const 0)))
        (set_local $c (i32.load offset=8 (i32.const 0)))
        (set_local $d (i32.load offset=12 (i32.const 0)))
        (set_local $e (i32.load offset=16 (i32.const 0)))
        (set_local $f (i32.load offset=20 (i32.const 0)))
        (set_local $g (i32.load offset=24 (i32.const 0)))
        (set_local $h (i32.load offset=28 (i32.const 0)))
        
        ;; ROUND 0

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K0 + W0
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w0)) (i32.load offset=0 (i32.const 32))))
        (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

        ;; (call $i32.log (get_local $mem)) ;; 
        ;; (call $i32.log (get_local $ch_res)) ;; 
        ;; (call $i32.log (get_local $maj_res)) ;;
        ;; (call $i32.log (get_local $big_sig1_res)) ;;
        ;; (call $i32.log (get_local $big_sig0_res)) ;;
        ;; (call $i32.log (get_local $w0))
        ;; (call $i32.log (i32.load (i32.const 32))) ;;
        ;; (call $i32.log (get_local $T1))
        ;; (call $i32.log (get_local $T2)) ;;
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

        ;; ROUND 1

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K1 + W1
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w1)) (i32.load offset=4 (i32.const 32))))
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

        ;; ROUND 2

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K2 + W2
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w2)) (i32.load offset=8 (i32.const 32))))
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

        ;; ROUND 3

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K3 + W3
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w3)) (i32.load offset=12 (i32.const 32))))
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

        ;; ROUND 4

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K4 + W4
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w4)) (i32.load offset=16 (i32.const 32))))
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

        ;; ROUND 5

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K5 + W5
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w5)) (i32.load offset=20 (i32.const 32))))
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

        ;; ROUND 6

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K6 + W6
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w6)) (i32.load offset=24 (i32.const 32))))
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

        ;; ROUND 7

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K7 + W7
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w7)) (i32.load offset=28 (i32.const 32))))
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

        ;; ROUND 8

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K8 + W8
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w8)) (i32.load offset=32 (i32.const 32))))
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

        ;; ROUND 9

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K9 + W9
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w9)) (i32.load offset=36 (i32.const 32))))
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

        ;; ROUND 10

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K10 + W10
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w10)) (i32.load offset=40 (i32.const 32))))
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

        ;; ROUND 11

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K11 + W11
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w11)) (i32.load offset=44 (i32.const 32))))
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

        ;; ROUND 12

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K12 + W12
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w12)) (i32.load offset=48 (i32.const 32))))
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

        ;; ROUND 13

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K13 + W13
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w13)) (i32.load offset=52 (i32.const 32))))
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

        ;; ROUND 14

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K14 + W14
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w14)) (i32.load offset=56 (i32.const 32))))
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

        ;; ROUND 15

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K15 + W15
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w15)) (i32.load offset=60 (i32.const 32))))
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

        ;; ROUND 16

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K16 + W16
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w16)) (i32.load offset=64 (i32.const 32))))
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

        ;; ROUND 17

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K17 + W17
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w17)) (i32.load offset=68 (i32.const 32))))
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

        ;; ROUND 18

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K18 + W18
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w18)) (i32.load offset=72 (i32.const 32))))
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

        ;; ROUND 19

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K19 + W19
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w19)) (i32.load offset=76 (i32.const 32))))
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

        ;; ROUND 20

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K20 + W20
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w20)) (i32.load offset=80 (i32.const 32))))
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

        ;; ROUND 21

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K21 + W21
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w21)) (i32.load offset=84 (i32.const 32))))
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

        ;; ROUND 22

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K22 + W22
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w22)) (i32.load offset=88 (i32.const 32))))
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

        ;; ROUND 23

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K23 + W23
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w23)) (i32.load offset=92 (i32.const 32))))
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

        ;; ROUND 24

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K24 + W24
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w24)) (i32.load offset=96 (i32.const 32))))
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

        ;; ROUND 25

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K25 + W25
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w25)) (i32.load offset=100 (i32.const 32))))
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

        ;; ROUND 26

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K26 + W26
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w26)) (i32.load offset=104 (i32.const 32))))
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

        ;; ROUND 27

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K27 + W27
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w27)) (i32.load offset=108 (i32.const 32))))
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

        ;; ROUND 28

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K28 + W28
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w28)) (i32.load offset=112 (i32.const 32))))
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

        ;; ROUND 29

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K29 + W29
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w29)) (i32.load offset=116 (i32.const 32))))
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

        ;; ROUND 30

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K30 + W30
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w30)) (i32.load offset=120 (i32.const 32))))
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

        ;; ROUND 31

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K31 + W31
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w31)) (i32.load offset=124 (i32.const 32))))
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

        ;; ROUND 32

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K32 + W32
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w32)) (i32.load offset=128 (i32.const 32))))
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

        ;; ROUND 33

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K33 + W33
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w33)) (i32.load offset=132 (i32.const 32))))
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

        ;; ROUND 34

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K34 + W34
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w34)) (i32.load offset=136 (i32.const 32))))
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

        ;; ROUND 35

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K35 + W35
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w35)) (i32.load offset=140 (i32.const 32))))
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

        ;; ROUND 36

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K36 + W36
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w36)) (i32.load offset=144 (i32.const 32))))
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

        ;; ROUND 37

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K37 + W37
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w37)) (i32.load offset=148 (i32.const 32))))
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

        ;; ROUND 38

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K38 + W38
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w38)) (i32.load offset=152 (i32.const 32))))
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

        ;; ROUND 39

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K39 + W39
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w39)) (i32.load offset=156 (i32.const 32))))
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

        ;; ROUND 40

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K40 + W40
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w40)) (i32.load offset=160 (i32.const 32))))
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

        ;; ROUND 41

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K41 + W41
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w41)) (i32.load offset=164 (i32.const 32))))
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

        ;; ROUND 42

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K42 + W42
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w42)) (i32.load offset=168 (i32.const 32))))
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

        ;; ROUND 43

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K43 + W43
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w43)) (i32.load offset=172 (i32.const 32))))
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

        ;; ROUND 44

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K44 + W44
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w44)) (i32.load offset=176 (i32.const 32))))
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

        ;; ROUND 45

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K45 + W45
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w45)) (i32.load offset=180 (i32.const 32))))
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

        ;; ROUND 46

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K46 + W46
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w46)) (i32.load offset=184 (i32.const 32))))
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

        ;; ROUND 47

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K47 + W47
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w47)) (i32.load offset=188 (i32.const 32))))
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

        ;; ROUND 48

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K48 + W48
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w48)) (i32.load offset=192 (i32.const 32))))
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

        ;; ROUND 49

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K49 + W49
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w49)) (i32.load offset=196 (i32.const 32))))
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

        ;; ROUND 50

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K50 + W50
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w50)) (i32.load offset=200 (i32.const 32))))
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

        ;; ROUND 51

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K51 + W51
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w51)) (i32.load offset=204 (i32.const 32))))
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

        ;; ROUND 52

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K52 + W52
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w52)) (i32.load offset=208 (i32.const 32))))
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

        ;; ROUND 53

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K53 + W53
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w53)) (i32.load offset=212 (i32.const 32))))
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

        ;; ROUND 54

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K54 + W54
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w54)) (i32.load offset=216 (i32.const 32))))
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

        ;; ROUND 55

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K55 + W55
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w55)) (i32.load offset=220 (i32.const 32))))
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

        ;; ROUND 56

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K56 + W56
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w56)) (i32.load offset=224 (i32.const 32))))
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

        ;; ROUND 57

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K57 + W57
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w57)) (i32.load offset=228 (i32.const 32))))
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

        ;; ROUND 58

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K58 + W58
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w58)) (i32.load offset=232 (i32.const 32))))
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

        ;; ROUND 59

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K59 + W59
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w59)) (i32.load offset=236 (i32.const 32))))
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

        ;; ROUND 60

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K60 + W60
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w60)) (i32.load offset=240 (i32.const 32))))
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

        ;; ROUND 61

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K61 + W61
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w61)) (i32.load offset=244 (i32.const 32))))
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

        ;; ROUND 62

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K62 + W62
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w62)) (i32.load offset=248 (i32.const 32))))
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

        ;; ROUND 63

        ;; precompute intermediate values

        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K63 + W63
        ;; T2 = big_sig0(a) + Maj(a, b, c)

        (set_local $ch_res (call $Ch (get_local $e) (get_local $f) (get_local $g)))
        (set_local $maj_res (call $Maj (get_local $a) (get_local $b) (get_local $c)))
        (set_local $big_sig0_res (call $big_sig0 (get_local $a)))
        (set_local $big_sig1_res (call $big_sig1 (get_local $e)))

        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w63)) (i32.load offset=252 (i32.const 32))))
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

        
        ;; HASH COMPLETE FOR MESSAGE BLOCK
        ;; store hash values
        (set_local $h1 (i32.load offset=0  (i32.const 0)))
        (set_local $h2 (i32.load offset=4  (i32.const 0)))
        (set_local $h3 (i32.load offset=8  (i32.const 0)))
        (set_local $h4 (i32.load offset=12 (i32.const 0)))
        (set_local $h5 (i32.load offset=16 (i32.const 0)))
        (set_local $h6 (i32.load offset=20 (i32.const 0)))
        (set_local $h7 (i32.load offset=24 (i32.const 0)))
        (set_local $h8 (i32.load offset=28 (i32.const 0)))

        (i32.store offset=0  (i32.const 0) (i32.add (get_local $h1) (get_local $a))) ;;(i32.load offset=0  (get_local $mem))))
        (i32.store offset=4  (i32.const 0) (i32.add (get_local $h2) (get_local $b))) ;;(i32.load offset=4  (get_local $mem))))
        (i32.store offset=8  (i32.const 0) (i32.add (get_local $h3) (get_local $c))) ;;(i32.load offset=8  (get_local $mem))))
        (i32.store offset=12 (i32.const 0) (i32.add (get_local $h4) (get_local $d))) ;;(i32.load offset=12 (get_local $mem))))
        (i32.store offset=16 (i32.const 0) (i32.add (get_local $h5) (get_local $e))) ;;(i32.load offset=16 (get_local $mem))))
        (i32.store offset=20 (i32.const 0) (i32.add (get_local $h6) (get_local $f))) ;;(i32.load offset=20 (get_local $mem))))
        (i32.store offset=24 (i32.const 0) (i32.add (get_local $h7) (get_local $g))) ;;(i32.load offset=24 (get_local $mem))))
        (i32.store offset=28 (i32.const 0) (i32.add (get_local $h8) (get_local $h))))) ;;(i32.load offset=28 (get_local $mem))))))
