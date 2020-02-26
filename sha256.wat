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
                (i64.shl (get_local $0)
                    (i64.const 32)))
            ;; Lower limb
            (i32.wrap/i64 (get_local $0))))

    (func $i64.log_tee
        (param $0 i64)
        (result i64)
        (call $i64.log (get_local $0))
        (return (get_local $0)))
        
    (func $sha256 (export "sha256") (param $ctx i32) (param $input i32) (param $input_end i32) (param $final i32)
        (result i32)

        ;; storage schema:
        ;; [0..32] - hash state
        ;; [32..92] - store words between updates
        ;; [92..100] - number of bytes read between across all updates (64bit)

        (local $i i32)
        (local $ptr i32)
        (local $bytes_read i64)
        (local $end_point i32)
        (local $block_position i32)
        (local $last_word i32)
        (local $leftover i32)

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

        (local $k0 i32)  (local $k1 i32)  (local $k2 i32)  (local $k3 i32)  
        (local $k4 i32)  (local $k5 i32)  (local $k6 i32)  (local $k7 i32) 
        (local $k8 i32)  (local $k9 i32)  (local $k10 i32) (local $k11 i32) 
        (local $k12 i32) (local $k13 i32) (local $k14 i32) (local $k15 i32)
        (local $k16 i32) (local $k17 i32) (local $k18 i32) (local $k19 i32) 
        (local $k20 i32) (local $k21 i32) (local $k22 i32) (local $k23 i32)
        (local $k24 i32) (local $k25 i32) (local $k26 i32) (local $k27 i32) 
        (local $k28 i32) (local $k29 i32) (local $k30 i32) (local $k31 i32)
        (local $k32 i32) (local $k33 i32) (local $k34 i32) (local $k35 i32) 
        (local $k36 i32) (local $k37 i32) (local $k38 i32) (local $k39 i32)
        (local $k40 i32) (local $k41 i32) (local $k42 i32) (local $k43 i32) 
        (local $k44 i32) (local $k45 i32) (local $k46 i32) (local $k47 i32)
        (local $k48 i32) (local $k49 i32) (local $k50 i32) (local $k51 i32) 
        (local $k52 i32) (local $k53 i32) (local $k54 i32) (local $k55 i32)
        (local $k56 i32) (local $k57 i32) (local $k58 i32) (local $k59 i32) 
        (local $k60 i32) (local $k61 i32) (local $k62 i32) (local $k63 i32)

        ;; load word constants
        (set_local $k0  (i32.xor (i32.const 0x428a2f98) (i32.const 0)))
        (set_local $k1  (i32.xor (i32.const 0x71374491) (i32.const 0)))
        (set_local $k2  (i32.xor (i32.const 0xb5c0fbcf) (i32.const 0)))
        (set_local $k3  (i32.xor (i32.const 0xe9b5dba5) (i32.const 0)))
        (set_local $k4  (i32.xor (i32.const 0x3956c25b) (i32.const 0)))
        (set_local $k5  (i32.xor (i32.const 0x59f111f1) (i32.const 0)))
        (set_local $k6  (i32.xor (i32.const 0x923f82a4) (i32.const 0)))
        (set_local $k7  (i32.xor (i32.const 0xab1c5ed5) (i32.const 0)))
        (set_local $k8  (i32.xor (i32.const 0xd807aa98) (i32.const 0)))
        (set_local $k9  (i32.xor (i32.const 0x12835b01) (i32.const 0)))
        (set_local $k10 (i32.xor (i32.const 0x243185be) (i32.const 0)))
        (set_local $k11 (i32.xor (i32.const 0x550c7dc3) (i32.const 0)))
        (set_local $k12 (i32.xor (i32.const 0x72be5d74) (i32.const 0)))
        (set_local $k13 (i32.xor (i32.const 0x80deb1fe) (i32.const 0)))
        (set_local $k14 (i32.xor (i32.const 0x9bdc06a7) (i32.const 0)))
        (set_local $k15 (i32.xor (i32.const 0xc19bf174) (i32.const 0)))
        (set_local $k16 (i32.xor (i32.const 0xe49b69c1) (i32.const 0)))
        (set_local $k17 (i32.xor (i32.const 0xefbe4786) (i32.const 0)))
        (set_local $k18 (i32.xor (i32.const 0x0fc19dc6) (i32.const 0)))
        (set_local $k19 (i32.xor (i32.const 0x240ca1cc) (i32.const 0)))
        (set_local $k20 (i32.xor (i32.const 0x2de92c6f) (i32.const 0)))
        (set_local $k21 (i32.xor (i32.const 0x4a7484aa) (i32.const 0)))
        (set_local $k22 (i32.xor (i32.const 0x5cb0a9dc) (i32.const 0)))
        (set_local $k23 (i32.xor (i32.const 0x76f988da) (i32.const 0)))
        (set_local $k24 (i32.xor (i32.const 0x983e5152) (i32.const 0)))
        (set_local $k25 (i32.xor (i32.const 0xa831c66d) (i32.const 0)))
        (set_local $k26 (i32.xor (i32.const 0xb00327c8) (i32.const 0)))
        (set_local $k27 (i32.xor (i32.const 0xbf597fc7) (i32.const 0)))
        (set_local $k28 (i32.xor (i32.const 0xc6e00bf3) (i32.const 0)))
        (set_local $k29 (i32.xor (i32.const 0xd5a79147) (i32.const 0)))
        (set_local $k30 (i32.xor (i32.const 0x06ca6351) (i32.const 0)))
        (set_local $k31 (i32.xor (i32.const 0x14292967) (i32.const 0)))
        (set_local $k32 (i32.xor (i32.const 0x27b70a85) (i32.const 0)))
        (set_local $k33 (i32.xor (i32.const 0x2e1b2138) (i32.const 0)))
        (set_local $k34 (i32.xor (i32.const 0x4d2c6dfc) (i32.const 0)))
        (set_local $k35 (i32.xor (i32.const 0x53380d13) (i32.const 0)))
        (set_local $k36 (i32.xor (i32.const 0x650a7354) (i32.const 0)))
        (set_local $k37 (i32.xor (i32.const 0x766a0abb) (i32.const 0)))
        (set_local $k38 (i32.xor (i32.const 0x81c2c92e) (i32.const 0)))
        (set_local $k39 (i32.xor (i32.const 0x92722c85) (i32.const 0)))
        (set_local $k40 (i32.xor (i32.const 0xa2bfe8a1) (i32.const 0)))
        (set_local $k41 (i32.xor (i32.const 0xa81a664b) (i32.const 0)))
        (set_local $k42 (i32.xor (i32.const 0xc24b8b70) (i32.const 0)))
        (set_local $k43 (i32.xor (i32.const 0xc76c51a3) (i32.const 0)))
        (set_local $k44 (i32.xor (i32.const 0xd192e819) (i32.const 0)))
        (set_local $k45 (i32.xor (i32.const 0xd6990624) (i32.const 0)))
        (set_local $k46 (i32.xor (i32.const 0xf40e3585) (i32.const 0)))
        (set_local $k47 (i32.xor (i32.const 0x106aa070) (i32.const 0)))
        (set_local $k48 (i32.xor (i32.const 0x19a4c116) (i32.const 0)))
        (set_local $k49 (i32.xor (i32.const 0x1e376c08) (i32.const 0)))
        (set_local $k50 (i32.xor (i32.const 0x2748774c) (i32.const 0)))
        (set_local $k51 (i32.xor (i32.const 0x34b0bcb5) (i32.const 0)))
        (set_local $k52 (i32.xor (i32.const 0x391c0cb3) (i32.const 0)))
        (set_local $k53 (i32.xor (i32.const 0x4ed8aa4a) (i32.const 0)))
        (set_local $k54 (i32.xor (i32.const 0x5b9cca4f) (i32.const 0)))
        (set_local $k55 (i32.xor (i32.const 0x682e6ff3) (i32.const 0)))
        (set_local $k56 (i32.xor (i32.const 0x748f82ee) (i32.const 0)))
        (set_local $k57 (i32.xor (i32.const 0x78a5636f) (i32.const 0)))
        (set_local $k58 (i32.xor (i32.const 0x84c87814) (i32.const 0)))
        (set_local $k59 (i32.xor (i32.const 0x8cc70208) (i32.const 0)))
        (set_local $k60 (i32.xor (i32.const 0x90befffa) (i32.const 0)))
        (set_local $k61 (i32.xor (i32.const 0xa4506ceb) (i32.const 0)))
        (set_local $k62 (i32.xor (i32.const 0xbef9a3f7) (i32.const 0)))
        (set_local $k63 (i32.xor (i32.const 0xc67178f2) (i32.const 0)))

        ;; load current block_position
        (set_local $bytes_read (i64.load offset=92 (get_local $ctx)))
        (set_local $block_position (i32.wrap/i64 (i64.rem_u (get_local $bytes_read) (i64.const 64))))
        (set_local $leftover (i32.rem_u (get_local $input_end) (i32.const 4)))
        (set_local $end_point (i32.sub (get_local $input_end) (get_local $leftover)))

        ;;  store inital state
        (if (i64.lt_u (get_local $bytes_read) (i64.const 64))
            (then
                (i32.store offset=0  (get_local $ctx) (i32.xor (i32.const 0x6a09e667) (i32.const 0)))
                (i32.store offset=4  (get_local $ctx) (i32.xor (i32.const 0xbb67ae85) (i32.const 0)))
                (i32.store offset=8  (get_local $ctx) (i32.xor (i32.const 0x3c6ef372) (i32.const 0)))   
                (i32.store offset=12 (get_local $ctx) (i32.xor (i32.const 0xa54ff53a) (i32.const 0)))
                (i32.store offset=16 (get_local $ctx) (i32.xor (i32.const 0x510e527f) (i32.const 0)))
                (i32.store offset=20 (get_local $ctx) (i32.xor (i32.const 0x9b05688c) (i32.const 0)))
                (i32.store offset=24 (get_local $ctx) (i32.xor (i32.const 0x1f83d9ab) (i32.const 0)))
                (i32.store offset=28 (get_local $ctx) (i32.xor (i32.const 0x5be0cd19) (i32.const 0)))))

        (set_local $ptr (get_local $input))
        (block $break
            (block $0
                (block $1
                    (block $2
                        (block $3
                            (block $4
                                (block $5
                                    (block $6
                                        (block $7
                                            (block $8
                                                (block $9
                                                    (block $10
                                                        (block $11
                                                            (block $12
                                                                (block $13
                                                                    (block $14
                                                                        (block $15
                                                                            (block $switch
                                                                                (br_table $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15
                                                                                    (i32.div_u (get_local $block_position) (i32.const 4)))))

                                                                            (set_local $w15 (get_local $last_word))
                                                                            (set_local $w14 (i32.load offset=88 (get_local $ctx)))
                                                                            (set_local $w13 (i32.load offset=84 (get_local $ctx)))
                                                                            (set_local $w12 (i32.load offset=80 (get_local $ctx)))
                                                                            (set_local $w11 (i32.load offset=76 (get_local $ctx)))
                                                                            (set_local $w10 (i32.load offset=72 (get_local $ctx)))
                                                                            (set_local $w9 (i32.load offset=68 (get_local $ctx)))
                                                                            (set_local $w8 (i32.load offset=64 (get_local $ctx)))
                                                                            (set_local $w7 (i32.load offset=60 (get_local $ctx)))
                                                                            (set_local $w6 (i32.load offset=56 (get_local $ctx)))
                                                                            (set_local $w5 (i32.load offset=52 (get_local $ctx)))
                                                                            (set_local $w4 (i32.load offset=48 (get_local $ctx)))
                                                                            (set_local $w3 (i32.load offset=44 (get_local $ctx)))
                                                                            (set_local $w2 (i32.load offset=40 (get_local $ctx)))
                                                                            (set_local $w1 (i32.load offset=36 (get_local $ctx)))
                                                                            (set_local $w0 (i32.load offset=32 (get_local $ctx)))
                                                                            (br $break))

                                                                        (set_local $w13 (i32.load offset=84 (get_local $ctx)))
                                                                        (set_local $w12 (i32.load offset=80 (get_local $ctx)))
                                                                        (set_local $w11 (i32.load offset=76 (get_local $ctx)))
                                                                        (set_local $w10 (i32.load offset=72 (get_local $ctx)))
                                                                        (set_local $w9 (i32.load offset=68 (get_local $ctx)))
                                                                        (set_local $w8 (i32.load offset=64 (get_local $ctx)))
                                                                        (set_local $w7 (i32.load offset=60 (get_local $ctx)))
                                                                        (set_local $w6 (i32.load offset=56 (get_local $ctx)))
                                                                        (set_local $w5 (i32.load offset=52 (get_local $ctx)))
                                                                        (set_local $w4 (i32.load offset=48 (get_local $ctx)))
                                                                        (set_local $w3 (i32.load offset=44 (get_local $ctx)))
                                                                        (set_local $w2 (i32.load offset=40 (get_local $ctx)))
                                                                        (set_local $w1 (i32.load offset=36 (get_local $ctx)))
                                                                        (set_local $w0 (i32.load offset=32 (get_local $ctx)))
                                                                        (br $break))

                                                                    (set_local $w12 (i32.load offset=80 (get_local $ctx)))
                                                                    (set_local $w11 (i32.load offset=76 (get_local $ctx)))
                                                                    (set_local $w10 (i32.load offset=72 (get_local $ctx)))
                                                                    (set_local $w9 (i32.load offset=68 (get_local $ctx)))
                                                                    (set_local $w8 (i32.load offset=64 (get_local $ctx)))
                                                                    (set_local $w7 (i32.load offset=60 (get_local $ctx)))
                                                                    (set_local $w6 (i32.load offset=56 (get_local $ctx)))
                                                                    (set_local $w5 (i32.load offset=52 (get_local $ctx)))
                                                                    (set_local $w4 (i32.load offset=48 (get_local $ctx)))
                                                                    (set_local $w3 (i32.load offset=44 (get_local $ctx)))
                                                                    (set_local $w2 (i32.load offset=40 (get_local $ctx)))
                                                                    (set_local $w1 (i32.load offset=36 (get_local $ctx)))
                                                                    (set_local $w0 (i32.load offset=32 (get_local $ctx)))
                                                                    (br $break))

                                                                (set_local $w11 (i32.load offset=76 (get_local $ctx)))
                                                                (set_local $w10 (i32.load offset=72 (get_local $ctx)))
                                                                (set_local $w9 (i32.load offset=68 (get_local $ctx)))
                                                                (set_local $w8 (i32.load offset=64 (get_local $ctx)))
                                                                (set_local $w7 (i32.load offset=60 (get_local $ctx)))
                                                                (set_local $w6 (i32.load offset=56 (get_local $ctx)))
                                                                (set_local $w5 (i32.load offset=52 (get_local $ctx)))
                                                                (set_local $w4 (i32.load offset=48 (get_local $ctx)))
                                                                (set_local $w3 (i32.load offset=44 (get_local $ctx)))
                                                                (set_local $w2 (i32.load offset=40 (get_local $ctx)))
                                                                (set_local $w1 (i32.load offset=36 (get_local $ctx)))
                                                                (set_local $w0 (i32.load offset=32 (get_local $ctx)))
                                                                (br $break))

                                                            (set_local $w10 (i32.load offset=72 (get_local $ctx)))
                                                            (set_local $w9 (i32.load offset=68 (get_local $ctx)))
                                                            (set_local $w8 (i32.load offset=64 (get_local $ctx)))
                                                            (set_local $w7 (i32.load offset=60 (get_local $ctx)))
                                                            (set_local $w6 (i32.load offset=56 (get_local $ctx)))
                                                            (set_local $w5 (i32.load offset=52 (get_local $ctx)))
                                                            (set_local $w4 (i32.load offset=48 (get_local $ctx)))
                                                            (set_local $w3 (i32.load offset=44 (get_local $ctx)))
                                                            (set_local $w2 (i32.load offset=40 (get_local $ctx)))
                                                            (set_local $w1 (i32.load offset=36 (get_local $ctx)))
                                                            (set_local $w0 (i32.load offset=32 (get_local $ctx)))
                                                            (br $break))

                                                        (set_local $w9 (i32.load offset=68 (get_local $ctx)))
                                                        (set_local $w8 (i32.load offset=64 (get_local $ctx)))
                                                        (set_local $w7 (i32.load offset=60 (get_local $ctx)))
                                                        (set_local $w6 (i32.load offset=56 (get_local $ctx)))
                                                        (set_local $w5 (i32.load offset=52 (get_local $ctx)))
                                                        (set_local $w4 (i32.load offset=48 (get_local $ctx)))
                                                        (set_local $w3 (i32.load offset=44 (get_local $ctx)))
                                                        (set_local $w2 (i32.load offset=40 (get_local $ctx)))
                                                        (set_local $w1 (i32.load offset=36 (get_local $ctx)))
                                                        (set_local $w0 (i32.load offset=32 (get_local $ctx)))
                                                        (br $break))

                                                    (set_local $w8 (i32.load offset=64 (get_local $ctx)))
                                                    (set_local $w7 (i32.load offset=60 (get_local $ctx)))
                                                    (set_local $w6 (i32.load offset=56 (get_local $ctx)))
                                                    (set_local $w5 (i32.load offset=52 (get_local $ctx)))
                                                    (set_local $w4 (i32.load offset=48 (get_local $ctx)))
                                                    (set_local $w3 (i32.load offset=44 (get_local $ctx)))
                                                    (set_local $w2 (i32.load offset=40 (get_local $ctx)))
                                                    (set_local $w1 (i32.load offset=36 (get_local $ctx)))
                                                    (set_local $w0 (i32.load offset=32 (get_local $ctx)))
                                                    (br $break))

                                                (set_local $w7 (i32.load offset=60 (get_local $ctx)))
                                                (set_local $w6 (i32.load offset=56 (get_local $ctx)))
                                                (set_local $w5 (i32.load offset=52 (get_local $ctx)))
                                                (set_local $w4 (i32.load offset=48 (get_local $ctx)))
                                                (set_local $w3 (i32.load offset=44 (get_local $ctx)))
                                                (set_local $w2 (i32.load offset=40 (get_local $ctx)))
                                                (set_local $w1 (i32.load offset=36 (get_local $ctx)))
                                                (set_local $w0 (i32.load offset=32 (get_local $ctx)))
                                                (br $break))

                                            (set_local $w6 (i32.load offset=56 (get_local $ctx)))
                                            (set_local $w5 (i32.load offset=52 (get_local $ctx)))
                                            (set_local $w4 (i32.load offset=48 (get_local $ctx)))
                                            (set_local $w3 (i32.load offset=44 (get_local $ctx)))
                                            (set_local $w2 (i32.load offset=40 (get_local $ctx)))
                                            (set_local $w1 (i32.load offset=36 (get_local $ctx)))
                                            (set_local $w0 (i32.load offset=32 (get_local $ctx)))
                                            (br $break))

                                        (set_local $w5 (i32.load offset=52 (get_local $ctx)))
                                        (set_local $w4 (i32.load offset=48 (get_local $ctx)))
                                        (set_local $w3 (i32.load offset=44 (get_local $ctx)))
                                        (set_local $w2 (i32.load offset=40 (get_local $ctx)))
                                        (set_local $w1 (i32.load offset=36 (get_local $ctx)))
                                        (set_local $w0 (i32.load offset=32 (get_local $ctx)))
                                        (br $break))

                                    (set_local $w4 (i32.load offset=48 (get_local $ctx)))
                                    (set_local $w3 (i32.load offset=44 (get_local $ctx)))
                                    (set_local $w2 (i32.load offset=40 (get_local $ctx)))
                                    (set_local $w1 (i32.load offset=36 (get_local $ctx)))
                                    (set_local $w0 (i32.load offset=32 (get_local $ctx)))
                                    (br $break))

                                (set_local $w3 (i32.load offset=44 (get_local $ctx)))
                                (set_local $w2 (i32.load offset=40 (get_local $ctx)))
                                (set_local $w1 (i32.load offset=36 (get_local $ctx)))
                                (set_local $w0 (i32.load offset=32 (get_local $ctx)))
                                (br $break))

                            (set_local $w2 (i32.load offset=40 (get_local $ctx)))
                            (set_local $w1 (i32.load offset=36 (get_local $ctx)))
                            (set_local $w0 (i32.load offset=32 (get_local $ctx)))
                            (br $break))

                        (set_local $w1 (i32.load offset=36 (get_local $ctx)))
                        (set_local $w0 (i32.load offset=32 (get_local $ctx)))                
                        (br $break))
                    
                    (set_local $w0 (i32.load offset=32 (get_local $ctx)))
                    (br $break))

                (br $break))

        (block $end
            (loop $start
                (if (i32.eq (get_local $block_position) (i32.const 64))
                    (then
                        (set_local $block_position (i32.const 0))
                        (set_local $bytes_read (i64.add (get_local $bytes_read) (i64.const 64)))

                        ;; words 16-63 are defined by w[j] <- sig1(w[j-2]) + w[j-7] + sig0(w[j-15]) + w[j-16]
                        (set_local $w16 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w14) (i32.const 17)) (i32.rotr (get_local $w14) (i32.const 19))) (i32.shr_u (get_local $w14) (i32.const 10))) (get_local $w9)) (i32.xor (i32.xor (i32.rotr (get_local $w1) (i32.const 7)) (i32.rotr (get_local $w1) (i32.const 18))) (i32.shr_u (get_local $w1) (i32.const 3))) (get_local $w0))))
                        (set_local $w17 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w15) (i32.const 17)) (i32.rotr (get_local $w15) (i32.const 19))) (i32.shr_u (get_local $w15) (i32.const 10))) (get_local $w10)) (i32.xor (i32.xor (i32.rotr (get_local $w2) (i32.const 7)) (i32.rotr (get_local $w2) (i32.const 18))) (i32.shr_u (get_local $w2) (i32.const 3))) (get_local $w1))))
                        (set_local $w18 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w16) (i32.const 17)) (i32.rotr (get_local $w16) (i32.const 19))) (i32.shr_u (get_local $w16) (i32.const 10))) (get_local $w11)) (i32.xor (i32.xor (i32.rotr (get_local $w3) (i32.const 7)) (i32.rotr (get_local $w3) (i32.const 18))) (i32.shr_u (get_local $w3) (i32.const 3))) (get_local $w2))))
                        (set_local $w19 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w17) (i32.const 17)) (i32.rotr (get_local $w17) (i32.const 19))) (i32.shr_u (get_local $w17) (i32.const 10))) (get_local $w12)) (i32.xor (i32.xor (i32.rotr (get_local $w4) (i32.const 7)) (i32.rotr (get_local $w4) (i32.const 18))) (i32.shr_u (get_local $w4) (i32.const 3))) (get_local $w3))))
                        (set_local $w20 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w18) (i32.const 17)) (i32.rotr (get_local $w18) (i32.const 19))) (i32.shr_u (get_local $w18) (i32.const 10))) (get_local $w13)) (i32.xor (i32.xor (i32.rotr (get_local $w5) (i32.const 7)) (i32.rotr (get_local $w5) (i32.const 18))) (i32.shr_u (get_local $w5) (i32.const 3))) (get_local $w4))))
                        (set_local $w21 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w19) (i32.const 17)) (i32.rotr (get_local $w19) (i32.const 19))) (i32.shr_u (get_local $w19) (i32.const 10))) (get_local $w14)) (i32.xor (i32.xor (i32.rotr (get_local $w6) (i32.const 7)) (i32.rotr (get_local $w6) (i32.const 18))) (i32.shr_u (get_local $w6) (i32.const 3))) (get_local $w5))))
                        (set_local $w22 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w20) (i32.const 17)) (i32.rotr (get_local $w20) (i32.const 19))) (i32.shr_u (get_local $w20) (i32.const 10))) (get_local $w15)) (i32.xor (i32.xor (i32.rotr (get_local $w7) (i32.const 7)) (i32.rotr (get_local $w7) (i32.const 18))) (i32.shr_u (get_local $w7) (i32.const 3))) (get_local $w6))))
                        (set_local $w23 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w21) (i32.const 17)) (i32.rotr (get_local $w21) (i32.const 19))) (i32.shr_u (get_local $w21) (i32.const 10))) (get_local $w16)) (i32.xor (i32.xor (i32.rotr (get_local $w8) (i32.const 7)) (i32.rotr (get_local $w8) (i32.const 18))) (i32.shr_u (get_local $w8) (i32.const 3))) (get_local $w7))))
                        (set_local $w24 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w22) (i32.const 17)) (i32.rotr (get_local $w22) (i32.const 19))) (i32.shr_u (get_local $w22) (i32.const 10))) (get_local $w17)) (i32.xor (i32.xor (i32.rotr (get_local $w9) (i32.const 7)) (i32.rotr (get_local $w9) (i32.const 18))) (i32.shr_u (get_local $w9) (i32.const 3))) (get_local $w8))))
                        (set_local $w25 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w23) (i32.const 17)) (i32.rotr (get_local $w23) (i32.const 19))) (i32.shr_u (get_local $w23) (i32.const 10))) (get_local $w18)) (i32.xor (i32.xor (i32.rotr (get_local $w10) (i32.const 7)) (i32.rotr (get_local $w10) (i32.const 18))) (i32.shr_u (get_local $w10) (i32.const 3))) (get_local $w9))))
                        (set_local $w26 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w24) (i32.const 17)) (i32.rotr (get_local $w24) (i32.const 19))) (i32.shr_u (get_local $w24) (i32.const 10))) (get_local $w19)) (i32.xor (i32.xor (i32.rotr (get_local $w11) (i32.const 7)) (i32.rotr (get_local $w11) (i32.const 18))) (i32.shr_u (get_local $w11) (i32.const 3))) (get_local $w10))))
                        (set_local $w27 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w25) (i32.const 17)) (i32.rotr (get_local $w25) (i32.const 19))) (i32.shr_u (get_local $w25) (i32.const 10))) (get_local $w20)) (i32.xor (i32.xor (i32.rotr (get_local $w12) (i32.const 7)) (i32.rotr (get_local $w12) (i32.const 18))) (i32.shr_u (get_local $w12) (i32.const 3))) (get_local $w11))))
                        (set_local $w28 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w26) (i32.const 17)) (i32.rotr (get_local $w26) (i32.const 19))) (i32.shr_u (get_local $w26) (i32.const 10))) (get_local $w21)) (i32.xor (i32.xor (i32.rotr (get_local $w13) (i32.const 7)) (i32.rotr (get_local $w13) (i32.const 18))) (i32.shr_u (get_local $w13) (i32.const 3))) (get_local $w12))))
                        (set_local $w29 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w27) (i32.const 17)) (i32.rotr (get_local $w27) (i32.const 19))) (i32.shr_u (get_local $w27) (i32.const 10))) (get_local $w22)) (i32.xor (i32.xor (i32.rotr (get_local $w14) (i32.const 7)) (i32.rotr (get_local $w14) (i32.const 18))) (i32.shr_u (get_local $w14) (i32.const 3))) (get_local $w13))))
                        (set_local $w30 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w28) (i32.const 17)) (i32.rotr (get_local $w28) (i32.const 19))) (i32.shr_u (get_local $w28) (i32.const 10))) (get_local $w23)) (i32.xor (i32.xor (i32.rotr (get_local $w15) (i32.const 7)) (i32.rotr (get_local $w15) (i32.const 18))) (i32.shr_u (get_local $w15) (i32.const 3))) (get_local $w14))))
                        (set_local $w31 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w29) (i32.const 17)) (i32.rotr (get_local $w29) (i32.const 19))) (i32.shr_u (get_local $w29) (i32.const 10))) (get_local $w24)) (i32.xor (i32.xor (i32.rotr (get_local $w16) (i32.const 7)) (i32.rotr (get_local $w16) (i32.const 18))) (i32.shr_u (get_local $w16) (i32.const 3))) (get_local $w15))))
                        (set_local $w32 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w30) (i32.const 17)) (i32.rotr (get_local $w30) (i32.const 19))) (i32.shr_u (get_local $w30) (i32.const 10))) (get_local $w25)) (i32.xor (i32.xor (i32.rotr (get_local $w17) (i32.const 7)) (i32.rotr (get_local $w17) (i32.const 18))) (i32.shr_u (get_local $w17) (i32.const 3))) (get_local $w16))))
                        (set_local $w33 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w31) (i32.const 17)) (i32.rotr (get_local $w31) (i32.const 19))) (i32.shr_u (get_local $w31) (i32.const 10))) (get_local $w26)) (i32.xor (i32.xor (i32.rotr (get_local $w18) (i32.const 7)) (i32.rotr (get_local $w18) (i32.const 18))) (i32.shr_u (get_local $w18) (i32.const 3))) (get_local $w17))))
                        (set_local $w34 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w32) (i32.const 17)) (i32.rotr (get_local $w32) (i32.const 19))) (i32.shr_u (get_local $w32) (i32.const 10))) (get_local $w27)) (i32.xor (i32.xor (i32.rotr (get_local $w19) (i32.const 7)) (i32.rotr (get_local $w19) (i32.const 18))) (i32.shr_u (get_local $w19) (i32.const 3))) (get_local $w18))))
                        (set_local $w35 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w33) (i32.const 17)) (i32.rotr (get_local $w33) (i32.const 19))) (i32.shr_u (get_local $w33) (i32.const 10))) (get_local $w28)) (i32.xor (i32.xor (i32.rotr (get_local $w20) (i32.const 7)) (i32.rotr (get_local $w20) (i32.const 18))) (i32.shr_u (get_local $w20) (i32.const 3))) (get_local $w19))))
                        (set_local $w36 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w34) (i32.const 17)) (i32.rotr (get_local $w34) (i32.const 19))) (i32.shr_u (get_local $w34) (i32.const 10))) (get_local $w29)) (i32.xor (i32.xor (i32.rotr (get_local $w21) (i32.const 7)) (i32.rotr (get_local $w21) (i32.const 18))) (i32.shr_u (get_local $w21) (i32.const 3))) (get_local $w20))))
                        (set_local $w37 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w35) (i32.const 17)) (i32.rotr (get_local $w35) (i32.const 19))) (i32.shr_u (get_local $w35) (i32.const 10))) (get_local $w30)) (i32.xor (i32.xor (i32.rotr (get_local $w22) (i32.const 7)) (i32.rotr (get_local $w22) (i32.const 18))) (i32.shr_u (get_local $w22) (i32.const 3))) (get_local $w21))))
                        (set_local $w38 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w36) (i32.const 17)) (i32.rotr (get_local $w36) (i32.const 19))) (i32.shr_u (get_local $w36) (i32.const 10))) (get_local $w31)) (i32.xor (i32.xor (i32.rotr (get_local $w23) (i32.const 7)) (i32.rotr (get_local $w23) (i32.const 18))) (i32.shr_u (get_local $w23) (i32.const 3))) (get_local $w22))))
                        (set_local $w39 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w37) (i32.const 17)) (i32.rotr (get_local $w37) (i32.const 19))) (i32.shr_u (get_local $w37) (i32.const 10))) (get_local $w32)) (i32.xor (i32.xor (i32.rotr (get_local $w24) (i32.const 7)) (i32.rotr (get_local $w24) (i32.const 18))) (i32.shr_u (get_local $w24) (i32.const 3))) (get_local $w23))))
                        (set_local $w40 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w38) (i32.const 17)) (i32.rotr (get_local $w38) (i32.const 19))) (i32.shr_u (get_local $w38) (i32.const 10))) (get_local $w33)) (i32.xor (i32.xor (i32.rotr (get_local $w25) (i32.const 7)) (i32.rotr (get_local $w25) (i32.const 18))) (i32.shr_u (get_local $w25) (i32.const 3))) (get_local $w24))))
                        (set_local $w41 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w39) (i32.const 17)) (i32.rotr (get_local $w39) (i32.const 19))) (i32.shr_u (get_local $w39) (i32.const 10))) (get_local $w34)) (i32.xor (i32.xor (i32.rotr (get_local $w26) (i32.const 7)) (i32.rotr (get_local $w26) (i32.const 18))) (i32.shr_u (get_local $w26) (i32.const 3))) (get_local $w25))))
                        (set_local $w42 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w40) (i32.const 17)) (i32.rotr (get_local $w40) (i32.const 19))) (i32.shr_u (get_local $w40) (i32.const 10))) (get_local $w35)) (i32.xor (i32.xor (i32.rotr (get_local $w27) (i32.const 7)) (i32.rotr (get_local $w27) (i32.const 18))) (i32.shr_u (get_local $w27) (i32.const 3))) (get_local $w26))))
                        (set_local $w43 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w41) (i32.const 17)) (i32.rotr (get_local $w41) (i32.const 19))) (i32.shr_u (get_local $w41) (i32.const 10))) (get_local $w36)) (i32.xor (i32.xor (i32.rotr (get_local $w28) (i32.const 7)) (i32.rotr (get_local $w28) (i32.const 18))) (i32.shr_u (get_local $w28) (i32.const 3))) (get_local $w27))))
                        (set_local $w44 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w42) (i32.const 17)) (i32.rotr (get_local $w42) (i32.const 19))) (i32.shr_u (get_local $w42) (i32.const 10))) (get_local $w37)) (i32.xor (i32.xor (i32.rotr (get_local $w29) (i32.const 7)) (i32.rotr (get_local $w29) (i32.const 18))) (i32.shr_u (get_local $w29) (i32.const 3))) (get_local $w28))))
                        (set_local $w45 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w43) (i32.const 17)) (i32.rotr (get_local $w43) (i32.const 19))) (i32.shr_u (get_local $w43) (i32.const 10))) (get_local $w38)) (i32.xor (i32.xor (i32.rotr (get_local $w30) (i32.const 7)) (i32.rotr (get_local $w30) (i32.const 18))) (i32.shr_u (get_local $w30) (i32.const 3))) (get_local $w29))))
                        (set_local $w46 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w44) (i32.const 17)) (i32.rotr (get_local $w44) (i32.const 19))) (i32.shr_u (get_local $w44) (i32.const 10))) (get_local $w39)) (i32.xor (i32.xor (i32.rotr (get_local $w31) (i32.const 7)) (i32.rotr (get_local $w31) (i32.const 18))) (i32.shr_u (get_local $w31) (i32.const 3))) (get_local $w30))))
                        (set_local $w47 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w45) (i32.const 17)) (i32.rotr (get_local $w45) (i32.const 19))) (i32.shr_u (get_local $w45) (i32.const 10))) (get_local $w40)) (i32.xor (i32.xor (i32.rotr (get_local $w32) (i32.const 7)) (i32.rotr (get_local $w32) (i32.const 18))) (i32.shr_u (get_local $w32) (i32.const 3))) (get_local $w31))))
                        (set_local $w48 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w46) (i32.const 17)) (i32.rotr (get_local $w46) (i32.const 19))) (i32.shr_u (get_local $w46) (i32.const 10))) (get_local $w41)) (i32.xor (i32.xor (i32.rotr (get_local $w33) (i32.const 7)) (i32.rotr (get_local $w33) (i32.const 18))) (i32.shr_u (get_local $w33) (i32.const 3))) (get_local $w32))))
                        (set_local $w49 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w47) (i32.const 17)) (i32.rotr (get_local $w47) (i32.const 19))) (i32.shr_u (get_local $w47) (i32.const 10))) (get_local $w42)) (i32.xor (i32.xor (i32.rotr (get_local $w34) (i32.const 7)) (i32.rotr (get_local $w34) (i32.const 18))) (i32.shr_u (get_local $w34) (i32.const 3))) (get_local $w33))))
                        (set_local $w50 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w48) (i32.const 17)) (i32.rotr (get_local $w48) (i32.const 19))) (i32.shr_u (get_local $w48) (i32.const 10))) (get_local $w43)) (i32.xor (i32.xor (i32.rotr (get_local $w35) (i32.const 7)) (i32.rotr (get_local $w35) (i32.const 18))) (i32.shr_u (get_local $w35) (i32.const 3))) (get_local $w34))))
                        (set_local $w51 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w49) (i32.const 17)) (i32.rotr (get_local $w49) (i32.const 19))) (i32.shr_u (get_local $w49) (i32.const 10))) (get_local $w44)) (i32.xor (i32.xor (i32.rotr (get_local $w36) (i32.const 7)) (i32.rotr (get_local $w36) (i32.const 18))) (i32.shr_u (get_local $w36) (i32.const 3))) (get_local $w35))))
                        (set_local $w52 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w50) (i32.const 17)) (i32.rotr (get_local $w50) (i32.const 19))) (i32.shr_u (get_local $w50) (i32.const 10))) (get_local $w45)) (i32.xor (i32.xor (i32.rotr (get_local $w37) (i32.const 7)) (i32.rotr (get_local $w37) (i32.const 18))) (i32.shr_u (get_local $w37) (i32.const 3))) (get_local $w36))))
                        (set_local $w53 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w51) (i32.const 17)) (i32.rotr (get_local $w51) (i32.const 19))) (i32.shr_u (get_local $w51) (i32.const 10))) (get_local $w46)) (i32.xor (i32.xor (i32.rotr (get_local $w38) (i32.const 7)) (i32.rotr (get_local $w38) (i32.const 18))) (i32.shr_u (get_local $w38) (i32.const 3))) (get_local $w37))))
                        (set_local $w54 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w52) (i32.const 17)) (i32.rotr (get_local $w52) (i32.const 19))) (i32.shr_u (get_local $w52) (i32.const 10))) (get_local $w47)) (i32.xor (i32.xor (i32.rotr (get_local $w39) (i32.const 7)) (i32.rotr (get_local $w39) (i32.const 18))) (i32.shr_u (get_local $w39) (i32.const 3))) (get_local $w38))))
                        (set_local $w55 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w53) (i32.const 17)) (i32.rotr (get_local $w53) (i32.const 19))) (i32.shr_u (get_local $w53) (i32.const 10))) (get_local $w48)) (i32.xor (i32.xor (i32.rotr (get_local $w40) (i32.const 7)) (i32.rotr (get_local $w40) (i32.const 18))) (i32.shr_u (get_local $w40) (i32.const 3))) (get_local $w39))))
                        (set_local $w56 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w54) (i32.const 17)) (i32.rotr (get_local $w54) (i32.const 19))) (i32.shr_u (get_local $w54) (i32.const 10))) (get_local $w49)) (i32.xor (i32.xor (i32.rotr (get_local $w41) (i32.const 7)) (i32.rotr (get_local $w41) (i32.const 18))) (i32.shr_u (get_local $w41) (i32.const 3))) (get_local $w40))))
                        (set_local $w57 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w55) (i32.const 17)) (i32.rotr (get_local $w55) (i32.const 19))) (i32.shr_u (get_local $w55) (i32.const 10))) (get_local $w50)) (i32.xor (i32.xor (i32.rotr (get_local $w42) (i32.const 7)) (i32.rotr (get_local $w42) (i32.const 18))) (i32.shr_u (get_local $w42) (i32.const 3))) (get_local $w41))))
                        (set_local $w58 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w56) (i32.const 17)) (i32.rotr (get_local $w56) (i32.const 19))) (i32.shr_u (get_local $w56) (i32.const 10))) (get_local $w51)) (i32.xor (i32.xor (i32.rotr (get_local $w43) (i32.const 7)) (i32.rotr (get_local $w43) (i32.const 18))) (i32.shr_u (get_local $w43) (i32.const 3))) (get_local $w42))))
                        (set_local $w59 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w57) (i32.const 17)) (i32.rotr (get_local $w57) (i32.const 19))) (i32.shr_u (get_local $w57) (i32.const 10))) (get_local $w52)) (i32.xor (i32.xor (i32.rotr (get_local $w44) (i32.const 7)) (i32.rotr (get_local $w44) (i32.const 18))) (i32.shr_u (get_local $w44) (i32.const 3))) (get_local $w43))))
                        (set_local $w60 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w58) (i32.const 17)) (i32.rotr (get_local $w58) (i32.const 19))) (i32.shr_u (get_local $w58) (i32.const 10))) (get_local $w53)) (i32.xor (i32.xor (i32.rotr (get_local $w45) (i32.const 7)) (i32.rotr (get_local $w45) (i32.const 18))) (i32.shr_u (get_local $w45) (i32.const 3))) (get_local $w44))))
                        (set_local $w61 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w59) (i32.const 17)) (i32.rotr (get_local $w59) (i32.const 19))) (i32.shr_u (get_local $w59) (i32.const 10))) (get_local $w54)) (i32.xor (i32.xor (i32.rotr (get_local $w46) (i32.const 7)) (i32.rotr (get_local $w46) (i32.const 18))) (i32.shr_u (get_local $w46) (i32.const 3))) (get_local $w45))))
                        (set_local $w62 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w60) (i32.const 17)) (i32.rotr (get_local $w60) (i32.const 19))) (i32.shr_u (get_local $w60) (i32.const 10))) (get_local $w55)) (i32.xor (i32.xor (i32.rotr (get_local $w47) (i32.const 7)) (i32.rotr (get_local $w47) (i32.const 18))) (i32.shr_u (get_local $w47) (i32.const 3))) (get_local $w46))))
                        (set_local $w63 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w61) (i32.const 17)) (i32.rotr (get_local $w61) (i32.const 19))) (i32.shr_u (get_local $w61) (i32.const 10))) (get_local $w56)) (i32.xor (i32.xor (i32.rotr (get_local $w48) (i32.const 7)) (i32.rotr (get_local $w48) (i32.const 18))) (i32.shr_u (get_local $w48) (i32.const 3))) (get_local $w47))))


                        ;; load previous hash state
                        (set_local $a (i32.load offset=0 (get_local $ctx)))
                        (set_local $b (i32.load offset=4 (get_local $ctx)))
                        (set_local $c (i32.load offset=8 (get_local $ctx)))
                        (set_local $d (i32.load offset=12 (get_local $ctx)))
                        (set_local $e (i32.load offset=16 (get_local $ctx)))
                        (set_local $f (i32.load offset=20 (get_local $ctx)))
                        (set_local $g (i32.load offset=24 (get_local $ctx)))
                        (set_local $h (i32.load offset=28 (get_local $ctx)))

                        ;; ROUND 0

                        ;; precompute intermediate values

                        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K0 + W0
                        ;; T2 = big_sig0(a) + Maj(a, b, c)

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w0)) (get_local $k0)))
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

                        ;; ROUND 1

                        ;; precompute intermediate values

                        ;; T1 = h + big_sig1(e) + ch(e, f, g) + K1 + W1
                        ;; T2 = big_sig0(a) + Maj(a, b, c)

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w1)) (get_local $k1)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w2)) (get_local $k2)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w3)) (get_local $k3)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w4)) (get_local $k4)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w5)) (get_local $k5)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w6)) (get_local $k6)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w7)) (get_local $k7)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w8)) (get_local $k8)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w9)) (get_local $k9)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w10)) (get_local $k10)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w11)) (get_local $k11)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w12)) (get_local $k12)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w13)) (get_local $k13)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w14)) (get_local $k14)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w15)) (get_local $k15)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w16)) (get_local $k16)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w17)) (get_local $k17)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w18)) (get_local $k18)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w19)) (get_local $k19)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w20)) (get_local $k20)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w21)) (get_local $k21)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w22)) (get_local $k22)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w23)) (get_local $k23)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w24)) (get_local $k24)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w25)) (get_local $k25)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w26)) (get_local $k26)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w27)) (get_local $k27)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w28)) (get_local $k28)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w29)) (get_local $k29)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w30)) (get_local $k30)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w31)) (get_local $k31)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w32)) (get_local $k32)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w33)) (get_local $k33)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w34)) (get_local $k34)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w35)) (get_local $k35)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w36)) (get_local $k36)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w37)) (get_local $k37)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w38)) (get_local $k38)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w39)) (get_local $k39)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w40)) (get_local $k40)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w41)) (get_local $k41)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w42)) (get_local $k42)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w43)) (get_local $k43)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w44)) (get_local $k44)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w45)) (get_local $k45)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w46)) (get_local $k46)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w47)) (get_local $k47)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w48)) (get_local $k48)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w49)) (get_local $k49)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w50)) (get_local $k50)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w51)) (get_local $k51)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w52)) (get_local $k52)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w53)) (get_local $k53)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w54)) (get_local $k54)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w55)) (get_local $k55)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w56)) (get_local $k56)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w57)) (get_local $k57)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w58)) (get_local $k58)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w59)) (get_local $k59)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w60)) (get_local $k60)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w61)) (get_local $k61)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w62)) (get_local $k62)))
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

                        (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                        (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                        
                        (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                        (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                        (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w63)) (get_local $k63)))
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

                        ;; store hash state in between updates
                        (i32.store offset=0  (get_local $ctx) (i32.add (i32.load offset=0  (get_local $ctx)) (get_local $a)))
                        (i32.store offset=4  (get_local $ctx) (i32.add (i32.load offset=4  (get_local $ctx)) (get_local $b)))
                        (i32.store offset=8  (get_local $ctx) (i32.add (i32.load offset=8  (get_local $ctx)) (get_local $c)))
                        (i32.store offset=12 (get_local $ctx) (i32.add (i32.load offset=12 (get_local $ctx)) (get_local $d)))
                        (i32.store offset=16 (get_local $ctx) (i32.add (i32.load offset=16 (get_local $ctx)) (get_local $e)))
                        (i32.store offset=20 (get_local $ctx) (i32.add (i32.load offset=20 (get_local $ctx)) (get_local $f)))
                        (i32.store offset=24 (get_local $ctx) (i32.add (i32.load offset=24 (get_local $ctx)) (get_local $g)))
                        (i32.store offset=28 (get_local $ctx) (i32.add (i32.load offset=28 (get_local $ctx)) (get_local $h)))))

                        (br_if $end (i32.eq (get_local $ptr) (get_local $end_point)))

                (block $break
                    (block $0
                        (block $1
                            (block $2
                                (block $3
                                    (block $4
                                        (block $5
                                            (block $6
                                                (block $7
                                                    (block $8
                                                        (block $9
                                                            (block $10
                                                                (block $11
                                                                    (block $12
                                                                        (block $13
                                                                            (block $14
                                                                                (block $15
                                                                                    (block $switch
                                                                                        (br_table $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15
                                                                                            (i32.div_u (get_local $block_position) (i32.const 4)))))
                        
                                                                                    (get_local $ctx)
                                                                                    (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                                                                                    (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                                                                                    (i32.or)
                                                                                    (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                                                                    (i32.or)
                                                                                    (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                                                                    (i32.or)
                                                                                    (set_local $w15)

                                                                                    (br $break))
                        
                                                                                (get_local $ctx)
                                                                                (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                                                                                (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                                                                                (i32.or)
                                                                                (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                                                                (i32.or)
                                                                                (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                                                                (i32.or)
                                                                                (tee_local $w14)
                                                                                (i32.store offset=88)

                                                                                (br $break))
                        
                                                                            (get_local $ctx)
                                                                            (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                                                                            (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                                                                            (i32.or)
                                                                            (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                                                            (i32.or)
                                                                            (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                                                            (i32.or)
                                                                            (tee_local $w13)
                                                                            (i32.store offset=84)

                                                                            (br $break))
                        
                                                                        (get_local $ctx)
                                                                        (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                                                                        (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                                                                        (i32.or)
                                                                        (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                                                        (i32.or)
                                                                        (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                                                        (i32.or)
                                                                        (tee_local $w12)
                                                                        (i32.store offset=80)

                                                                        (br $break))
                        
                                                                    (get_local $ctx)
                                                                    (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                                                                    (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                                                                    (i32.or)
                                                                    (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                                                    (i32.or)
                                                                    (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                                                    (i32.or)
                                                                    (tee_local $w11)
                                                                    (i32.store offset=76)

                                                                    (br $break))
                        
                                                                (get_local $ctx)
                                                                (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                                                                (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                                                                (i32.or)
                                                                (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                                                (i32.or)
                                                                (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                                                (i32.or)
                                                                (tee_local $w10)
                                                                (i32.store offset=72)

                                                                (br $break))
                        
                                                            (get_local $ctx)
                                                            (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                                                            (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                                                            (i32.or)
                                                            (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                                            (i32.or)
                                                            (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                                            (i32.or)
                                                            (tee_local $w9)
                                                            (i32.store offset=68)

                                                            (br $break))
                        
                                                        (get_local $ctx)
                                                        (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                                                        (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                                                        (i32.or)
                                                        (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                                        (i32.or)
                                                        (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                                        (i32.or)
                                                        (tee_local $w8)
                                                        (i32.store offset=64)

                                                        (br $break))
                        
                                                    (get_local $ctx)
                                                    (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                                                    (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                                                    (i32.or)
                                                    (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                                    (i32.or)
                                                    (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                                    (i32.or)
                                                    (tee_local $w7)
                                                    (i32.store offset=60)

                                                    (br $break))
                        
                                                (get_local $ctx)
                                                (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                                                (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                                                (i32.or)
                                                (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                                (i32.or)
                                                (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                                (i32.or)
                                                (tee_local $w6)
                                                (i32.store offset=56)

                                                (br $break))
                        
                                            (get_local $ctx)
                                            (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                                            (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                                            (i32.or)
                                            (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                            (i32.or)
                                            (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                            (i32.or)
                                            (tee_local $w5)
                                            (i32.store offset=52)

                                            (br $break))
                        
                                        (get_local $ctx)
                                        (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                                        (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                                        (i32.or)
                                        (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                        (i32.or)
                                        (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                        (i32.or)
                                        (tee_local $w4)
                                        (i32.store offset=48)

                                        (br $break))

                                    (get_local $ctx)
                                    (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                                    (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                                    (i32.or)
                                    (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                    (i32.or)
                                    (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                    (i32.or)
                                    (tee_local $w3)
                                    (i32.store offset=44)

                                    (br $break))
                        
                                (get_local $ctx)
                                (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                                (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                                (i32.or)
                                (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                (i32.or)
                                (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                (i32.or)
                                (tee_local $w2)
                                (i32.store offset=40)

                                (br $break))
                        
                            (get_local $ctx)
                            (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                            (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                            (i32.or)
                            (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                            (i32.or)
                            (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                            (i32.or)
                            (tee_local $w1)
                            (i32.store offset=36)

                            (br $break))
                        
                        (get_local $ctx)
                        (i32.load8_u (i32.add (i32.const 3) (get_local $ptr)))
                        (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                        (i32.or)
                        (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                        (i32.or)
                        (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                        (i32.or)
                        (tee_local $w0)
                        (i32.store offset=32)

                        (br $break))
                
                (set_local $ptr (i32.add (get_local $ptr) (i32.const 4)))
                (set_local $block_position (i32.add (get_local $block_position) (i32.const 4)))
                (br $start)))
            
            (if (i32.ne (get_local $end_point) (get_local $input_end))
                    (then
                        (block $break
                            (block $0
                                (block $1
                                    (block $2
                                        (block $3
                                            (block $switch
                                                (br_table $0 $1 $2 $3 
                                                    (get_local $leftover))))
                                            
                                            (i32.const 0)
                                            (i32.shl (i32.load8_u (i32.add (i32.const 2) (get_local $ptr))) (i32.const 8))
                                            (i32.or)
                                            (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                            (i32.or)
                                            (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                            (i32.or)
                                            (set_local $last_word)
                                            (br $break))
                                        
                                        (i32.const 0)
                                        (i32.shl (i32.load8_u (i32.add (i32.const 1) (get_local $ptr))) (i32.const 16))
                                        (i32.or)
                                        (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                        (i32.or)
                                        (set_local $last_word)
                                        (br $break))
                                    
                                    (i32.const 0)
                                    (i32.shl (i32.load8_u (get_local $ptr)) (i32.const 24))
                                    (i32.or)
                                    (set_local $last_word)
                                    (br $break))
                                
                                (i32.const 0)
                                (set_local $last_word)
                                (br $break))))

        ;;  store block position
        (get_local $ctx)
        (get_local $bytes_read)
        (i64.const 64)
        (i64.div_u)
        (i64.const 64)
        (i64.mul)
        (get_local $block_position)
        (i64.extend_u/i32)
        (i64.add)
        (i64.store offset=92)

        ;;  store leftover bytes and return number of bytes modulo 4
        (i32.store (get_local $input) (i32.load (get_local $ptr)))

        (i32.store (get_local $input) (i32.load (get_local $ptr)))

        (if (i32.eq (get_local $final) (i32.const 1))
            (then
                (i32.shl (i32.const 0x80) (i32.mul (i32.sub (i32.const 3) (get_local $leftover)) (i32.const 8)))
                (get_local $last_word)
                (i32.or)
                (set_local $last_word)

                (set_local $bytes_read (i64.add (get_local $bytes_read) (i64.extend_u/i32 (get_local $leftover))))

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
                                                                                        (br_table $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15
                                                                                            (i32.div_u (get_local $block_position) (i32.const 4)))))
                                                                                    
                                                                                    (set_local $w14 (get_local $last_word))
                                                                                    (set_local $last_word (i32.const 0)))
                                                                            
                                                                                (set_local $w15 (get_local $last_word))
                                                                                (set_local $last_word (i32.const 0))

                                                                                ;; words 16-63 are defined by w[j] <- sig1(w[j-2]) + w[j-7] + sig0(w[j-15]) + w[j-16]
                                                                                (set_local $w16 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w14) (i32.const 17)) (i32.rotr (get_local $w14) (i32.const 19))) (i32.shr_u (get_local $w14) (i32.const 10))) (get_local $w9)) (i32.xor (i32.xor (i32.rotr (get_local $w1) (i32.const 7)) (i32.rotr (get_local $w1) (i32.const 18))) (i32.shr_u (get_local $w1) (i32.const 3))) (get_local $w0))))
                                                                                (set_local $w17 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w15) (i32.const 17)) (i32.rotr (get_local $w15) (i32.const 19))) (i32.shr_u (get_local $w15) (i32.const 10))) (get_local $w10)) (i32.xor (i32.xor (i32.rotr (get_local $w2) (i32.const 7)) (i32.rotr (get_local $w2) (i32.const 18))) (i32.shr_u (get_local $w2) (i32.const 3))) (get_local $w1))))
                                                                                (set_local $w18 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w16) (i32.const 17)) (i32.rotr (get_local $w16) (i32.const 19))) (i32.shr_u (get_local $w16) (i32.const 10))) (get_local $w11)) (i32.xor (i32.xor (i32.rotr (get_local $w3) (i32.const 7)) (i32.rotr (get_local $w3) (i32.const 18))) (i32.shr_u (get_local $w3) (i32.const 3))) (get_local $w2))))
                                                                                (set_local $w19 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w17) (i32.const 17)) (i32.rotr (get_local $w17) (i32.const 19))) (i32.shr_u (get_local $w17) (i32.const 10))) (get_local $w12)) (i32.xor (i32.xor (i32.rotr (get_local $w4) (i32.const 7)) (i32.rotr (get_local $w4) (i32.const 18))) (i32.shr_u (get_local $w4) (i32.const 3))) (get_local $w3))))
                                                                                (set_local $w20 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w18) (i32.const 17)) (i32.rotr (get_local $w18) (i32.const 19))) (i32.shr_u (get_local $w18) (i32.const 10))) (get_local $w13)) (i32.xor (i32.xor (i32.rotr (get_local $w5) (i32.const 7)) (i32.rotr (get_local $w5) (i32.const 18))) (i32.shr_u (get_local $w5) (i32.const 3))) (get_local $w4))))
                                                                                (set_local $w21 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w19) (i32.const 17)) (i32.rotr (get_local $w19) (i32.const 19))) (i32.shr_u (get_local $w19) (i32.const 10))) (get_local $w14)) (i32.xor (i32.xor (i32.rotr (get_local $w6) (i32.const 7)) (i32.rotr (get_local $w6) (i32.const 18))) (i32.shr_u (get_local $w6) (i32.const 3))) (get_local $w5))))
                                                                                (set_local $w22 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w20) (i32.const 17)) (i32.rotr (get_local $w20) (i32.const 19))) (i32.shr_u (get_local $w20) (i32.const 10))) (get_local $w15)) (i32.xor (i32.xor (i32.rotr (get_local $w7) (i32.const 7)) (i32.rotr (get_local $w7) (i32.const 18))) (i32.shr_u (get_local $w7) (i32.const 3))) (get_local $w6))))
                                                                                (set_local $w23 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w21) (i32.const 17)) (i32.rotr (get_local $w21) (i32.const 19))) (i32.shr_u (get_local $w21) (i32.const 10))) (get_local $w16)) (i32.xor (i32.xor (i32.rotr (get_local $w8) (i32.const 7)) (i32.rotr (get_local $w8) (i32.const 18))) (i32.shr_u (get_local $w8) (i32.const 3))) (get_local $w7))))
                                                                                (set_local $w24 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w22) (i32.const 17)) (i32.rotr (get_local $w22) (i32.const 19))) (i32.shr_u (get_local $w22) (i32.const 10))) (get_local $w17)) (i32.xor (i32.xor (i32.rotr (get_local $w9) (i32.const 7)) (i32.rotr (get_local $w9) (i32.const 18))) (i32.shr_u (get_local $w9) (i32.const 3))) (get_local $w8))))
                                                                                (set_local $w25 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w23) (i32.const 17)) (i32.rotr (get_local $w23) (i32.const 19))) (i32.shr_u (get_local $w23) (i32.const 10))) (get_local $w18)) (i32.xor (i32.xor (i32.rotr (get_local $w10) (i32.const 7)) (i32.rotr (get_local $w10) (i32.const 18))) (i32.shr_u (get_local $w10) (i32.const 3))) (get_local $w9))))
                                                                                (set_local $w26 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w24) (i32.const 17)) (i32.rotr (get_local $w24) (i32.const 19))) (i32.shr_u (get_local $w24) (i32.const 10))) (get_local $w19)) (i32.xor (i32.xor (i32.rotr (get_local $w11) (i32.const 7)) (i32.rotr (get_local $w11) (i32.const 18))) (i32.shr_u (get_local $w11) (i32.const 3))) (get_local $w10))))
                                                                                (set_local $w27 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w25) (i32.const 17)) (i32.rotr (get_local $w25) (i32.const 19))) (i32.shr_u (get_local $w25) (i32.const 10))) (get_local $w20)) (i32.xor (i32.xor (i32.rotr (get_local $w12) (i32.const 7)) (i32.rotr (get_local $w12) (i32.const 18))) (i32.shr_u (get_local $w12) (i32.const 3))) (get_local $w11))))
                                                                                (set_local $w28 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w26) (i32.const 17)) (i32.rotr (get_local $w26) (i32.const 19))) (i32.shr_u (get_local $w26) (i32.const 10))) (get_local $w21)) (i32.xor (i32.xor (i32.rotr (get_local $w13) (i32.const 7)) (i32.rotr (get_local $w13) (i32.const 18))) (i32.shr_u (get_local $w13) (i32.const 3))) (get_local $w12))))
                                                                                (set_local $w29 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w27) (i32.const 17)) (i32.rotr (get_local $w27) (i32.const 19))) (i32.shr_u (get_local $w27) (i32.const 10))) (get_local $w22)) (i32.xor (i32.xor (i32.rotr (get_local $w14) (i32.const 7)) (i32.rotr (get_local $w14) (i32.const 18))) (i32.shr_u (get_local $w14) (i32.const 3))) (get_local $w13))))
                                                                                (set_local $w30 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w28) (i32.const 17)) (i32.rotr (get_local $w28) (i32.const 19))) (i32.shr_u (get_local $w28) (i32.const 10))) (get_local $w23)) (i32.xor (i32.xor (i32.rotr (get_local $w15) (i32.const 7)) (i32.rotr (get_local $w15) (i32.const 18))) (i32.shr_u (get_local $w15) (i32.const 3))) (get_local $w14))))
                                                                                (set_local $w31 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w29) (i32.const 17)) (i32.rotr (get_local $w29) (i32.const 19))) (i32.shr_u (get_local $w29) (i32.const 10))) (get_local $w24)) (i32.xor (i32.xor (i32.rotr (get_local $w16) (i32.const 7)) (i32.rotr (get_local $w16) (i32.const 18))) (i32.shr_u (get_local $w16) (i32.const 3))) (get_local $w15))))
                                                                                (set_local $w32 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w30) (i32.const 17)) (i32.rotr (get_local $w30) (i32.const 19))) (i32.shr_u (get_local $w30) (i32.const 10))) (get_local $w25)) (i32.xor (i32.xor (i32.rotr (get_local $w17) (i32.const 7)) (i32.rotr (get_local $w17) (i32.const 18))) (i32.shr_u (get_local $w17) (i32.const 3))) (get_local $w16))))
                                                                                (set_local $w33 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w31) (i32.const 17)) (i32.rotr (get_local $w31) (i32.const 19))) (i32.shr_u (get_local $w31) (i32.const 10))) (get_local $w26)) (i32.xor (i32.xor (i32.rotr (get_local $w18) (i32.const 7)) (i32.rotr (get_local $w18) (i32.const 18))) (i32.shr_u (get_local $w18) (i32.const 3))) (get_local $w17))))
                                                                                (set_local $w34 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w32) (i32.const 17)) (i32.rotr (get_local $w32) (i32.const 19))) (i32.shr_u (get_local $w32) (i32.const 10))) (get_local $w27)) (i32.xor (i32.xor (i32.rotr (get_local $w19) (i32.const 7)) (i32.rotr (get_local $w19) (i32.const 18))) (i32.shr_u (get_local $w19) (i32.const 3))) (get_local $w18))))
                                                                                (set_local $w35 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w33) (i32.const 17)) (i32.rotr (get_local $w33) (i32.const 19))) (i32.shr_u (get_local $w33) (i32.const 10))) (get_local $w28)) (i32.xor (i32.xor (i32.rotr (get_local $w20) (i32.const 7)) (i32.rotr (get_local $w20) (i32.const 18))) (i32.shr_u (get_local $w20) (i32.const 3))) (get_local $w19))))
                                                                                (set_local $w36 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w34) (i32.const 17)) (i32.rotr (get_local $w34) (i32.const 19))) (i32.shr_u (get_local $w34) (i32.const 10))) (get_local $w29)) (i32.xor (i32.xor (i32.rotr (get_local $w21) (i32.const 7)) (i32.rotr (get_local $w21) (i32.const 18))) (i32.shr_u (get_local $w21) (i32.const 3))) (get_local $w20))))
                                                                                (set_local $w37 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w35) (i32.const 17)) (i32.rotr (get_local $w35) (i32.const 19))) (i32.shr_u (get_local $w35) (i32.const 10))) (get_local $w30)) (i32.xor (i32.xor (i32.rotr (get_local $w22) (i32.const 7)) (i32.rotr (get_local $w22) (i32.const 18))) (i32.shr_u (get_local $w22) (i32.const 3))) (get_local $w21))))
                                                                                (set_local $w38 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w36) (i32.const 17)) (i32.rotr (get_local $w36) (i32.const 19))) (i32.shr_u (get_local $w36) (i32.const 10))) (get_local $w31)) (i32.xor (i32.xor (i32.rotr (get_local $w23) (i32.const 7)) (i32.rotr (get_local $w23) (i32.const 18))) (i32.shr_u (get_local $w23) (i32.const 3))) (get_local $w22))))
                                                                                (set_local $w39 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w37) (i32.const 17)) (i32.rotr (get_local $w37) (i32.const 19))) (i32.shr_u (get_local $w37) (i32.const 10))) (get_local $w32)) (i32.xor (i32.xor (i32.rotr (get_local $w24) (i32.const 7)) (i32.rotr (get_local $w24) (i32.const 18))) (i32.shr_u (get_local $w24) (i32.const 3))) (get_local $w23))))
                                                                                (set_local $w40 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w38) (i32.const 17)) (i32.rotr (get_local $w38) (i32.const 19))) (i32.shr_u (get_local $w38) (i32.const 10))) (get_local $w33)) (i32.xor (i32.xor (i32.rotr (get_local $w25) (i32.const 7)) (i32.rotr (get_local $w25) (i32.const 18))) (i32.shr_u (get_local $w25) (i32.const 3))) (get_local $w24))))
                                                                                (set_local $w41 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w39) (i32.const 17)) (i32.rotr (get_local $w39) (i32.const 19))) (i32.shr_u (get_local $w39) (i32.const 10))) (get_local $w34)) (i32.xor (i32.xor (i32.rotr (get_local $w26) (i32.const 7)) (i32.rotr (get_local $w26) (i32.const 18))) (i32.shr_u (get_local $w26) (i32.const 3))) (get_local $w25))))
                                                                                (set_local $w42 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w40) (i32.const 17)) (i32.rotr (get_local $w40) (i32.const 19))) (i32.shr_u (get_local $w40) (i32.const 10))) (get_local $w35)) (i32.xor (i32.xor (i32.rotr (get_local $w27) (i32.const 7)) (i32.rotr (get_local $w27) (i32.const 18))) (i32.shr_u (get_local $w27) (i32.const 3))) (get_local $w26))))
                                                                                (set_local $w43 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w41) (i32.const 17)) (i32.rotr (get_local $w41) (i32.const 19))) (i32.shr_u (get_local $w41) (i32.const 10))) (get_local $w36)) (i32.xor (i32.xor (i32.rotr (get_local $w28) (i32.const 7)) (i32.rotr (get_local $w28) (i32.const 18))) (i32.shr_u (get_local $w28) (i32.const 3))) (get_local $w27))))
                                                                                (set_local $w44 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w42) (i32.const 17)) (i32.rotr (get_local $w42) (i32.const 19))) (i32.shr_u (get_local $w42) (i32.const 10))) (get_local $w37)) (i32.xor (i32.xor (i32.rotr (get_local $w29) (i32.const 7)) (i32.rotr (get_local $w29) (i32.const 18))) (i32.shr_u (get_local $w29) (i32.const 3))) (get_local $w28))))
                                                                                (set_local $w45 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w43) (i32.const 17)) (i32.rotr (get_local $w43) (i32.const 19))) (i32.shr_u (get_local $w43) (i32.const 10))) (get_local $w38)) (i32.xor (i32.xor (i32.rotr (get_local $w30) (i32.const 7)) (i32.rotr (get_local $w30) (i32.const 18))) (i32.shr_u (get_local $w30) (i32.const 3))) (get_local $w29))))
                                                                                (set_local $w46 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w44) (i32.const 17)) (i32.rotr (get_local $w44) (i32.const 19))) (i32.shr_u (get_local $w44) (i32.const 10))) (get_local $w39)) (i32.xor (i32.xor (i32.rotr (get_local $w31) (i32.const 7)) (i32.rotr (get_local $w31) (i32.const 18))) (i32.shr_u (get_local $w31) (i32.const 3))) (get_local $w30))))
                                                                                (set_local $w47 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w45) (i32.const 17)) (i32.rotr (get_local $w45) (i32.const 19))) (i32.shr_u (get_local $w45) (i32.const 10))) (get_local $w40)) (i32.xor (i32.xor (i32.rotr (get_local $w32) (i32.const 7)) (i32.rotr (get_local $w32) (i32.const 18))) (i32.shr_u (get_local $w32) (i32.const 3))) (get_local $w31))))
                                                                                (set_local $w48 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w46) (i32.const 17)) (i32.rotr (get_local $w46) (i32.const 19))) (i32.shr_u (get_local $w46) (i32.const 10))) (get_local $w41)) (i32.xor (i32.xor (i32.rotr (get_local $w33) (i32.const 7)) (i32.rotr (get_local $w33) (i32.const 18))) (i32.shr_u (get_local $w33) (i32.const 3))) (get_local $w32))))
                                                                                (set_local $w49 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w47) (i32.const 17)) (i32.rotr (get_local $w47) (i32.const 19))) (i32.shr_u (get_local $w47) (i32.const 10))) (get_local $w42)) (i32.xor (i32.xor (i32.rotr (get_local $w34) (i32.const 7)) (i32.rotr (get_local $w34) (i32.const 18))) (i32.shr_u (get_local $w34) (i32.const 3))) (get_local $w33))))
                                                                                (set_local $w50 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w48) (i32.const 17)) (i32.rotr (get_local $w48) (i32.const 19))) (i32.shr_u (get_local $w48) (i32.const 10))) (get_local $w43)) (i32.xor (i32.xor (i32.rotr (get_local $w35) (i32.const 7)) (i32.rotr (get_local $w35) (i32.const 18))) (i32.shr_u (get_local $w35) (i32.const 3))) (get_local $w34))))
                                                                                (set_local $w51 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w49) (i32.const 17)) (i32.rotr (get_local $w49) (i32.const 19))) (i32.shr_u (get_local $w49) (i32.const 10))) (get_local $w44)) (i32.xor (i32.xor (i32.rotr (get_local $w36) (i32.const 7)) (i32.rotr (get_local $w36) (i32.const 18))) (i32.shr_u (get_local $w36) (i32.const 3))) (get_local $w35))))
                                                                                (set_local $w52 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w50) (i32.const 17)) (i32.rotr (get_local $w50) (i32.const 19))) (i32.shr_u (get_local $w50) (i32.const 10))) (get_local $w45)) (i32.xor (i32.xor (i32.rotr (get_local $w37) (i32.const 7)) (i32.rotr (get_local $w37) (i32.const 18))) (i32.shr_u (get_local $w37) (i32.const 3))) (get_local $w36))))
                                                                                (set_local $w53 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w51) (i32.const 17)) (i32.rotr (get_local $w51) (i32.const 19))) (i32.shr_u (get_local $w51) (i32.const 10))) (get_local $w46)) (i32.xor (i32.xor (i32.rotr (get_local $w38) (i32.const 7)) (i32.rotr (get_local $w38) (i32.const 18))) (i32.shr_u (get_local $w38) (i32.const 3))) (get_local $w37))))
                                                                                (set_local $w54 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w52) (i32.const 17)) (i32.rotr (get_local $w52) (i32.const 19))) (i32.shr_u (get_local $w52) (i32.const 10))) (get_local $w47)) (i32.xor (i32.xor (i32.rotr (get_local $w39) (i32.const 7)) (i32.rotr (get_local $w39) (i32.const 18))) (i32.shr_u (get_local $w39) (i32.const 3))) (get_local $w38))))
                                                                                (set_local $w55 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w53) (i32.const 17)) (i32.rotr (get_local $w53) (i32.const 19))) (i32.shr_u (get_local $w53) (i32.const 10))) (get_local $w48)) (i32.xor (i32.xor (i32.rotr (get_local $w40) (i32.const 7)) (i32.rotr (get_local $w40) (i32.const 18))) (i32.shr_u (get_local $w40) (i32.const 3))) (get_local $w39))))
                                                                                (set_local $w56 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w54) (i32.const 17)) (i32.rotr (get_local $w54) (i32.const 19))) (i32.shr_u (get_local $w54) (i32.const 10))) (get_local $w49)) (i32.xor (i32.xor (i32.rotr (get_local $w41) (i32.const 7)) (i32.rotr (get_local $w41) (i32.const 18))) (i32.shr_u (get_local $w41) (i32.const 3))) (get_local $w40))))
                                                                                (set_local $w57 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w55) (i32.const 17)) (i32.rotr (get_local $w55) (i32.const 19))) (i32.shr_u (get_local $w55) (i32.const 10))) (get_local $w50)) (i32.xor (i32.xor (i32.rotr (get_local $w42) (i32.const 7)) (i32.rotr (get_local $w42) (i32.const 18))) (i32.shr_u (get_local $w42) (i32.const 3))) (get_local $w41))))
                                                                                (set_local $w58 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w56) (i32.const 17)) (i32.rotr (get_local $w56) (i32.const 19))) (i32.shr_u (get_local $w56) (i32.const 10))) (get_local $w51)) (i32.xor (i32.xor (i32.rotr (get_local $w43) (i32.const 7)) (i32.rotr (get_local $w43) (i32.const 18))) (i32.shr_u (get_local $w43) (i32.const 3))) (get_local $w42))))
                                                                                (set_local $w59 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w57) (i32.const 17)) (i32.rotr (get_local $w57) (i32.const 19))) (i32.shr_u (get_local $w57) (i32.const 10))) (get_local $w52)) (i32.xor (i32.xor (i32.rotr (get_local $w44) (i32.const 7)) (i32.rotr (get_local $w44) (i32.const 18))) (i32.shr_u (get_local $w44) (i32.const 3))) (get_local $w43))))
                                                                                (set_local $w60 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w58) (i32.const 17)) (i32.rotr (get_local $w58) (i32.const 19))) (i32.shr_u (get_local $w58) (i32.const 10))) (get_local $w53)) (i32.xor (i32.xor (i32.rotr (get_local $w45) (i32.const 7)) (i32.rotr (get_local $w45) (i32.const 18))) (i32.shr_u (get_local $w45) (i32.const 3))) (get_local $w44))))
                                                                                (set_local $w61 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w59) (i32.const 17)) (i32.rotr (get_local $w59) (i32.const 19))) (i32.shr_u (get_local $w59) (i32.const 10))) (get_local $w54)) (i32.xor (i32.xor (i32.rotr (get_local $w46) (i32.const 7)) (i32.rotr (get_local $w46) (i32.const 18))) (i32.shr_u (get_local $w46) (i32.const 3))) (get_local $w45))))
                                                                                (set_local $w62 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w60) (i32.const 17)) (i32.rotr (get_local $w60) (i32.const 19))) (i32.shr_u (get_local $w60) (i32.const 10))) (get_local $w55)) (i32.xor (i32.xor (i32.rotr (get_local $w47) (i32.const 7)) (i32.rotr (get_local $w47) (i32.const 18))) (i32.shr_u (get_local $w47) (i32.const 3))) (get_local $w46))))
                                                                                (set_local $w63 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w61) (i32.const 17)) (i32.rotr (get_local $w61) (i32.const 19))) (i32.shr_u (get_local $w61) (i32.const 10))) (get_local $w56)) (i32.xor (i32.xor (i32.rotr (get_local $w48) (i32.const 7)) (i32.rotr (get_local $w48) (i32.const 18))) (i32.shr_u (get_local $w48) (i32.const 3))) (get_local $w47))))


                                                                                ;; load previous hash state
                                                                                (set_local $a (i32.load offset=0 (get_local $ctx)))
                                                                                (set_local $b (i32.load offset=4 (get_local $ctx)))
                                                                                (set_local $c (i32.load offset=8 (get_local $ctx)))
                                                                                (set_local $d (i32.load offset=12 (get_local $ctx)))
                                                                                (set_local $e (i32.load offset=16 (get_local $ctx)))
                                                                                (set_local $f (i32.load offset=20 (get_local $ctx)))
                                                                                (set_local $g (i32.load offset=24 (get_local $ctx)))
                                                                                (set_local $h (i32.load offset=28 (get_local $ctx)))

                                                                                ;; ROUND 0

                                                                                ;; precompute intermediate values

                                                                                ;; T1 = h + big_sig1(e) + ch(e, f, g) + K0 + W0
                                                                                ;; T2 = big_sig0(a) + Maj(a, b, c)

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w0)) (get_local $k0)))
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

                                                                                ;; ROUND 1

                                                                                ;; precompute intermediate values

                                                                                ;; T1 = h + big_sig1(e) + ch(e, f, g) + K1 + W1
                                                                                ;; T2 = big_sig0(a) + Maj(a, b, c)

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w1)) (get_local $k1)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w2)) (get_local $k2)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w3)) (get_local $k3)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w4)) (get_local $k4)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w5)) (get_local $k5)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w6)) (get_local $k6)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w7)) (get_local $k7)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w8)) (get_local $k8)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w9)) (get_local $k9)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w10)) (get_local $k10)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w11)) (get_local $k11)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w12)) (get_local $k12)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w13)) (get_local $k13)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w14)) (get_local $k14)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w15)) (get_local $k15)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w16)) (get_local $k16)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w17)) (get_local $k17)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w18)) (get_local $k18)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w19)) (get_local $k19)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w20)) (get_local $k20)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w21)) (get_local $k21)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w22)) (get_local $k22)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w23)) (get_local $k23)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w24)) (get_local $k24)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w25)) (get_local $k25)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w26)) (get_local $k26)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w27)) (get_local $k27)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w28)) (get_local $k28)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w29)) (get_local $k29)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w30)) (get_local $k30)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w31)) (get_local $k31)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w32)) (get_local $k32)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w33)) (get_local $k33)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w34)) (get_local $k34)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w35)) (get_local $k35)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w36)) (get_local $k36)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w37)) (get_local $k37)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w38)) (get_local $k38)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w39)) (get_local $k39)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w40)) (get_local $k40)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w41)) (get_local $k41)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w42)) (get_local $k42)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w43)) (get_local $k43)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w44)) (get_local $k44)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w45)) (get_local $k45)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w46)) (get_local $k46)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w47)) (get_local $k47)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w48)) (get_local $k48)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w49)) (get_local $k49)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w50)) (get_local $k50)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w51)) (get_local $k51)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w52)) (get_local $k52)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w53)) (get_local $k53)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w54)) (get_local $k54)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w55)) (get_local $k55)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w56)) (get_local $k56)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w57)) (get_local $k57)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w58)) (get_local $k58)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w59)) (get_local $k59)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w60)) (get_local $k60)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w61)) (get_local $k61)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w62)) (get_local $k62)))
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

                                                                                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                                                                                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                                                                                
                                                                                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                                                                                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                                                                                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w63)) (get_local $k63)))
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

                                                                                (i32.store offset=0  (get_local $ctx) (i32.add (i32.load offset=0  (get_local $ctx)) (get_local $a)))
                                                                                (i32.store offset=4  (get_local $ctx) (i32.add (i32.load offset=4  (get_local $ctx)) (get_local $b)))
                                                                                (i32.store offset=8  (get_local $ctx) (i32.add (i32.load offset=8  (get_local $ctx)) (get_local $c)))
                                                                                (i32.store offset=12 (get_local $ctx) (i32.add (i32.load offset=12 (get_local $ctx)) (get_local $d)))
                                                                                (i32.store offset=16 (get_local $ctx) (i32.add (i32.load offset=16 (get_local $ctx)) (get_local $e)))
                                                                                (i32.store offset=20 (get_local $ctx) (i32.add (i32.load offset=20 (get_local $ctx)) (get_local $f)))
                                                                                (i32.store offset=24 (get_local $ctx) (i32.add (i32.load offset=24 (get_local $ctx)) (get_local $g)))
                                                                                (i32.store offset=28 (get_local $ctx) (i32.add (i32.load offset=28 (get_local $ctx)) (get_local $h))))

                                                                            (set_local $w0 (get_local $last_word))
                                                                            (set_local $last_word (i32.const 0)))

                                                                        (set_local $w1 (get_local $last_word))
                                                                        (set_local $last_word (i32.const 0)))

                                                                    (set_local $w2 (get_local $last_word))
                                                                    (set_local $last_word (i32.const 0)))

                                                                (set_local $w3 (get_local $last_word))
                                                                (set_local $last_word (i32.const 0)))

                                                            (set_local $w4 (get_local $last_word))
                                                            (set_local $last_word (i32.const 0)))

                                                        (set_local $w5 (get_local $last_word))
                                                        (set_local $last_word (i32.const 0)))

                                                    (set_local $w6 (get_local $last_word))
                                                    (set_local $last_word (i32.const 0)))

                                                (set_local $w7 (get_local $last_word))
                                                (set_local $last_word (i32.const 0)))

                                            (set_local $w8 (get_local $last_word))
                                            (set_local $last_word (i32.const 0)))

                                        (set_local $w9 (get_local $last_word))
                                        (set_local $last_word (i32.const 0)))

                                    (set_local $w10 (get_local $last_word))
                                    (set_local $last_word (i32.const 0)))

                                (set_local $w11 (get_local $last_word))
                                (set_local $last_word (i32.const 0)))

                            (set_local $w12 (get_local $last_word))
                            (set_local $last_word (i32.const 0)))

                        (set_local $w13 (get_local $last_word))
                        (set_local $last_word (i32.const 0)))
                
                (set_local $w14 (i32.wrap/i64 (i64.shr_u (i64.mul (get_local $bytes_read) (i64.const 8)) (i64.const 32))))
                (set_local $w15 (i32.wrap/i64 (i64.mul (get_local $bytes_read) (i64.const 8))))
            
                ;; words 16-63 are defined by w[j] <- sig1(w[j-2]) + w[j-7] + sig0(w[j-15]) + w[j-16]
                (set_local $w16 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w14) (i32.const 17)) (i32.rotr (get_local $w14) (i32.const 19))) (i32.shr_u (get_local $w14) (i32.const 10))) (get_local $w9)) (i32.xor (i32.xor (i32.rotr (get_local $w1) (i32.const 7)) (i32.rotr (get_local $w1) (i32.const 18))) (i32.shr_u (get_local $w1) (i32.const 3))) (get_local $w0))))
                (set_local $w17 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w15) (i32.const 17)) (i32.rotr (get_local $w15) (i32.const 19))) (i32.shr_u (get_local $w15) (i32.const 10))) (get_local $w10)) (i32.xor (i32.xor (i32.rotr (get_local $w2) (i32.const 7)) (i32.rotr (get_local $w2) (i32.const 18))) (i32.shr_u (get_local $w2) (i32.const 3))) (get_local $w1))))
                (set_local $w18 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w16) (i32.const 17)) (i32.rotr (get_local $w16) (i32.const 19))) (i32.shr_u (get_local $w16) (i32.const 10))) (get_local $w11)) (i32.xor (i32.xor (i32.rotr (get_local $w3) (i32.const 7)) (i32.rotr (get_local $w3) (i32.const 18))) (i32.shr_u (get_local $w3) (i32.const 3))) (get_local $w2))))
                (set_local $w19 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w17) (i32.const 17)) (i32.rotr (get_local $w17) (i32.const 19))) (i32.shr_u (get_local $w17) (i32.const 10))) (get_local $w12)) (i32.xor (i32.xor (i32.rotr (get_local $w4) (i32.const 7)) (i32.rotr (get_local $w4) (i32.const 18))) (i32.shr_u (get_local $w4) (i32.const 3))) (get_local $w3))))
                (set_local $w20 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w18) (i32.const 17)) (i32.rotr (get_local $w18) (i32.const 19))) (i32.shr_u (get_local $w18) (i32.const 10))) (get_local $w13)) (i32.xor (i32.xor (i32.rotr (get_local $w5) (i32.const 7)) (i32.rotr (get_local $w5) (i32.const 18))) (i32.shr_u (get_local $w5) (i32.const 3))) (get_local $w4))))
                (set_local $w21 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w19) (i32.const 17)) (i32.rotr (get_local $w19) (i32.const 19))) (i32.shr_u (get_local $w19) (i32.const 10))) (get_local $w14)) (i32.xor (i32.xor (i32.rotr (get_local $w6) (i32.const 7)) (i32.rotr (get_local $w6) (i32.const 18))) (i32.shr_u (get_local $w6) (i32.const 3))) (get_local $w5))))
                (set_local $w22 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w20) (i32.const 17)) (i32.rotr (get_local $w20) (i32.const 19))) (i32.shr_u (get_local $w20) (i32.const 10))) (get_local $w15)) (i32.xor (i32.xor (i32.rotr (get_local $w7) (i32.const 7)) (i32.rotr (get_local $w7) (i32.const 18))) (i32.shr_u (get_local $w7) (i32.const 3))) (get_local $w6))))
                (set_local $w23 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w21) (i32.const 17)) (i32.rotr (get_local $w21) (i32.const 19))) (i32.shr_u (get_local $w21) (i32.const 10))) (get_local $w16)) (i32.xor (i32.xor (i32.rotr (get_local $w8) (i32.const 7)) (i32.rotr (get_local $w8) (i32.const 18))) (i32.shr_u (get_local $w8) (i32.const 3))) (get_local $w7))))
                (set_local $w24 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w22) (i32.const 17)) (i32.rotr (get_local $w22) (i32.const 19))) (i32.shr_u (get_local $w22) (i32.const 10))) (get_local $w17)) (i32.xor (i32.xor (i32.rotr (get_local $w9) (i32.const 7)) (i32.rotr (get_local $w9) (i32.const 18))) (i32.shr_u (get_local $w9) (i32.const 3))) (get_local $w8))))
                (set_local $w25 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w23) (i32.const 17)) (i32.rotr (get_local $w23) (i32.const 19))) (i32.shr_u (get_local $w23) (i32.const 10))) (get_local $w18)) (i32.xor (i32.xor (i32.rotr (get_local $w10) (i32.const 7)) (i32.rotr (get_local $w10) (i32.const 18))) (i32.shr_u (get_local $w10) (i32.const 3))) (get_local $w9))))
                (set_local $w26 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w24) (i32.const 17)) (i32.rotr (get_local $w24) (i32.const 19))) (i32.shr_u (get_local $w24) (i32.const 10))) (get_local $w19)) (i32.xor (i32.xor (i32.rotr (get_local $w11) (i32.const 7)) (i32.rotr (get_local $w11) (i32.const 18))) (i32.shr_u (get_local $w11) (i32.const 3))) (get_local $w10))))
                (set_local $w27 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w25) (i32.const 17)) (i32.rotr (get_local $w25) (i32.const 19))) (i32.shr_u (get_local $w25) (i32.const 10))) (get_local $w20)) (i32.xor (i32.xor (i32.rotr (get_local $w12) (i32.const 7)) (i32.rotr (get_local $w12) (i32.const 18))) (i32.shr_u (get_local $w12) (i32.const 3))) (get_local $w11))))
                (set_local $w28 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w26) (i32.const 17)) (i32.rotr (get_local $w26) (i32.const 19))) (i32.shr_u (get_local $w26) (i32.const 10))) (get_local $w21)) (i32.xor (i32.xor (i32.rotr (get_local $w13) (i32.const 7)) (i32.rotr (get_local $w13) (i32.const 18))) (i32.shr_u (get_local $w13) (i32.const 3))) (get_local $w12))))
                (set_local $w29 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w27) (i32.const 17)) (i32.rotr (get_local $w27) (i32.const 19))) (i32.shr_u (get_local $w27) (i32.const 10))) (get_local $w22)) (i32.xor (i32.xor (i32.rotr (get_local $w14) (i32.const 7)) (i32.rotr (get_local $w14) (i32.const 18))) (i32.shr_u (get_local $w14) (i32.const 3))) (get_local $w13))))
                (set_local $w30 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w28) (i32.const 17)) (i32.rotr (get_local $w28) (i32.const 19))) (i32.shr_u (get_local $w28) (i32.const 10))) (get_local $w23)) (i32.xor (i32.xor (i32.rotr (get_local $w15) (i32.const 7)) (i32.rotr (get_local $w15) (i32.const 18))) (i32.shr_u (get_local $w15) (i32.const 3))) (get_local $w14))))
                (set_local $w31 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w29) (i32.const 17)) (i32.rotr (get_local $w29) (i32.const 19))) (i32.shr_u (get_local $w29) (i32.const 10))) (get_local $w24)) (i32.xor (i32.xor (i32.rotr (get_local $w16) (i32.const 7)) (i32.rotr (get_local $w16) (i32.const 18))) (i32.shr_u (get_local $w16) (i32.const 3))) (get_local $w15))))
                (set_local $w32 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w30) (i32.const 17)) (i32.rotr (get_local $w30) (i32.const 19))) (i32.shr_u (get_local $w30) (i32.const 10))) (get_local $w25)) (i32.xor (i32.xor (i32.rotr (get_local $w17) (i32.const 7)) (i32.rotr (get_local $w17) (i32.const 18))) (i32.shr_u (get_local $w17) (i32.const 3))) (get_local $w16))))
                (set_local $w33 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w31) (i32.const 17)) (i32.rotr (get_local $w31) (i32.const 19))) (i32.shr_u (get_local $w31) (i32.const 10))) (get_local $w26)) (i32.xor (i32.xor (i32.rotr (get_local $w18) (i32.const 7)) (i32.rotr (get_local $w18) (i32.const 18))) (i32.shr_u (get_local $w18) (i32.const 3))) (get_local $w17))))
                (set_local $w34 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w32) (i32.const 17)) (i32.rotr (get_local $w32) (i32.const 19))) (i32.shr_u (get_local $w32) (i32.const 10))) (get_local $w27)) (i32.xor (i32.xor (i32.rotr (get_local $w19) (i32.const 7)) (i32.rotr (get_local $w19) (i32.const 18))) (i32.shr_u (get_local $w19) (i32.const 3))) (get_local $w18))))
                (set_local $w35 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w33) (i32.const 17)) (i32.rotr (get_local $w33) (i32.const 19))) (i32.shr_u (get_local $w33) (i32.const 10))) (get_local $w28)) (i32.xor (i32.xor (i32.rotr (get_local $w20) (i32.const 7)) (i32.rotr (get_local $w20) (i32.const 18))) (i32.shr_u (get_local $w20) (i32.const 3))) (get_local $w19))))
                (set_local $w36 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w34) (i32.const 17)) (i32.rotr (get_local $w34) (i32.const 19))) (i32.shr_u (get_local $w34) (i32.const 10))) (get_local $w29)) (i32.xor (i32.xor (i32.rotr (get_local $w21) (i32.const 7)) (i32.rotr (get_local $w21) (i32.const 18))) (i32.shr_u (get_local $w21) (i32.const 3))) (get_local $w20))))
                (set_local $w37 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w35) (i32.const 17)) (i32.rotr (get_local $w35) (i32.const 19))) (i32.shr_u (get_local $w35) (i32.const 10))) (get_local $w30)) (i32.xor (i32.xor (i32.rotr (get_local $w22) (i32.const 7)) (i32.rotr (get_local $w22) (i32.const 18))) (i32.shr_u (get_local $w22) (i32.const 3))) (get_local $w21))))
                (set_local $w38 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w36) (i32.const 17)) (i32.rotr (get_local $w36) (i32.const 19))) (i32.shr_u (get_local $w36) (i32.const 10))) (get_local $w31)) (i32.xor (i32.xor (i32.rotr (get_local $w23) (i32.const 7)) (i32.rotr (get_local $w23) (i32.const 18))) (i32.shr_u (get_local $w23) (i32.const 3))) (get_local $w22))))
                (set_local $w39 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w37) (i32.const 17)) (i32.rotr (get_local $w37) (i32.const 19))) (i32.shr_u (get_local $w37) (i32.const 10))) (get_local $w32)) (i32.xor (i32.xor (i32.rotr (get_local $w24) (i32.const 7)) (i32.rotr (get_local $w24) (i32.const 18))) (i32.shr_u (get_local $w24) (i32.const 3))) (get_local $w23))))
                (set_local $w40 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w38) (i32.const 17)) (i32.rotr (get_local $w38) (i32.const 19))) (i32.shr_u (get_local $w38) (i32.const 10))) (get_local $w33)) (i32.xor (i32.xor (i32.rotr (get_local $w25) (i32.const 7)) (i32.rotr (get_local $w25) (i32.const 18))) (i32.shr_u (get_local $w25) (i32.const 3))) (get_local $w24))))
                (set_local $w41 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w39) (i32.const 17)) (i32.rotr (get_local $w39) (i32.const 19))) (i32.shr_u (get_local $w39) (i32.const 10))) (get_local $w34)) (i32.xor (i32.xor (i32.rotr (get_local $w26) (i32.const 7)) (i32.rotr (get_local $w26) (i32.const 18))) (i32.shr_u (get_local $w26) (i32.const 3))) (get_local $w25))))
                (set_local $w42 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w40) (i32.const 17)) (i32.rotr (get_local $w40) (i32.const 19))) (i32.shr_u (get_local $w40) (i32.const 10))) (get_local $w35)) (i32.xor (i32.xor (i32.rotr (get_local $w27) (i32.const 7)) (i32.rotr (get_local $w27) (i32.const 18))) (i32.shr_u (get_local $w27) (i32.const 3))) (get_local $w26))))
                (set_local $w43 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w41) (i32.const 17)) (i32.rotr (get_local $w41) (i32.const 19))) (i32.shr_u (get_local $w41) (i32.const 10))) (get_local $w36)) (i32.xor (i32.xor (i32.rotr (get_local $w28) (i32.const 7)) (i32.rotr (get_local $w28) (i32.const 18))) (i32.shr_u (get_local $w28) (i32.const 3))) (get_local $w27))))
                (set_local $w44 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w42) (i32.const 17)) (i32.rotr (get_local $w42) (i32.const 19))) (i32.shr_u (get_local $w42) (i32.const 10))) (get_local $w37)) (i32.xor (i32.xor (i32.rotr (get_local $w29) (i32.const 7)) (i32.rotr (get_local $w29) (i32.const 18))) (i32.shr_u (get_local $w29) (i32.const 3))) (get_local $w28))))
                (set_local $w45 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w43) (i32.const 17)) (i32.rotr (get_local $w43) (i32.const 19))) (i32.shr_u (get_local $w43) (i32.const 10))) (get_local $w38)) (i32.xor (i32.xor (i32.rotr (get_local $w30) (i32.const 7)) (i32.rotr (get_local $w30) (i32.const 18))) (i32.shr_u (get_local $w30) (i32.const 3))) (get_local $w29))))
                (set_local $w46 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w44) (i32.const 17)) (i32.rotr (get_local $w44) (i32.const 19))) (i32.shr_u (get_local $w44) (i32.const 10))) (get_local $w39)) (i32.xor (i32.xor (i32.rotr (get_local $w31) (i32.const 7)) (i32.rotr (get_local $w31) (i32.const 18))) (i32.shr_u (get_local $w31) (i32.const 3))) (get_local $w30))))
                (set_local $w47 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w45) (i32.const 17)) (i32.rotr (get_local $w45) (i32.const 19))) (i32.shr_u (get_local $w45) (i32.const 10))) (get_local $w40)) (i32.xor (i32.xor (i32.rotr (get_local $w32) (i32.const 7)) (i32.rotr (get_local $w32) (i32.const 18))) (i32.shr_u (get_local $w32) (i32.const 3))) (get_local $w31))))
                (set_local $w48 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w46) (i32.const 17)) (i32.rotr (get_local $w46) (i32.const 19))) (i32.shr_u (get_local $w46) (i32.const 10))) (get_local $w41)) (i32.xor (i32.xor (i32.rotr (get_local $w33) (i32.const 7)) (i32.rotr (get_local $w33) (i32.const 18))) (i32.shr_u (get_local $w33) (i32.const 3))) (get_local $w32))))
                (set_local $w49 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w47) (i32.const 17)) (i32.rotr (get_local $w47) (i32.const 19))) (i32.shr_u (get_local $w47) (i32.const 10))) (get_local $w42)) (i32.xor (i32.xor (i32.rotr (get_local $w34) (i32.const 7)) (i32.rotr (get_local $w34) (i32.const 18))) (i32.shr_u (get_local $w34) (i32.const 3))) (get_local $w33))))
                (set_local $w50 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w48) (i32.const 17)) (i32.rotr (get_local $w48) (i32.const 19))) (i32.shr_u (get_local $w48) (i32.const 10))) (get_local $w43)) (i32.xor (i32.xor (i32.rotr (get_local $w35) (i32.const 7)) (i32.rotr (get_local $w35) (i32.const 18))) (i32.shr_u (get_local $w35) (i32.const 3))) (get_local $w34))))
                (set_local $w51 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w49) (i32.const 17)) (i32.rotr (get_local $w49) (i32.const 19))) (i32.shr_u (get_local $w49) (i32.const 10))) (get_local $w44)) (i32.xor (i32.xor (i32.rotr (get_local $w36) (i32.const 7)) (i32.rotr (get_local $w36) (i32.const 18))) (i32.shr_u (get_local $w36) (i32.const 3))) (get_local $w35))))
                (set_local $w52 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w50) (i32.const 17)) (i32.rotr (get_local $w50) (i32.const 19))) (i32.shr_u (get_local $w50) (i32.const 10))) (get_local $w45)) (i32.xor (i32.xor (i32.rotr (get_local $w37) (i32.const 7)) (i32.rotr (get_local $w37) (i32.const 18))) (i32.shr_u (get_local $w37) (i32.const 3))) (get_local $w36))))
                (set_local $w53 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w51) (i32.const 17)) (i32.rotr (get_local $w51) (i32.const 19))) (i32.shr_u (get_local $w51) (i32.const 10))) (get_local $w46)) (i32.xor (i32.xor (i32.rotr (get_local $w38) (i32.const 7)) (i32.rotr (get_local $w38) (i32.const 18))) (i32.shr_u (get_local $w38) (i32.const 3))) (get_local $w37))))
                (set_local $w54 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w52) (i32.const 17)) (i32.rotr (get_local $w52) (i32.const 19))) (i32.shr_u (get_local $w52) (i32.const 10))) (get_local $w47)) (i32.xor (i32.xor (i32.rotr (get_local $w39) (i32.const 7)) (i32.rotr (get_local $w39) (i32.const 18))) (i32.shr_u (get_local $w39) (i32.const 3))) (get_local $w38))))
                (set_local $w55 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w53) (i32.const 17)) (i32.rotr (get_local $w53) (i32.const 19))) (i32.shr_u (get_local $w53) (i32.const 10))) (get_local $w48)) (i32.xor (i32.xor (i32.rotr (get_local $w40) (i32.const 7)) (i32.rotr (get_local $w40) (i32.const 18))) (i32.shr_u (get_local $w40) (i32.const 3))) (get_local $w39))))
                (set_local $w56 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w54) (i32.const 17)) (i32.rotr (get_local $w54) (i32.const 19))) (i32.shr_u (get_local $w54) (i32.const 10))) (get_local $w49)) (i32.xor (i32.xor (i32.rotr (get_local $w41) (i32.const 7)) (i32.rotr (get_local $w41) (i32.const 18))) (i32.shr_u (get_local $w41) (i32.const 3))) (get_local $w40))))
                (set_local $w57 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w55) (i32.const 17)) (i32.rotr (get_local $w55) (i32.const 19))) (i32.shr_u (get_local $w55) (i32.const 10))) (get_local $w50)) (i32.xor (i32.xor (i32.rotr (get_local $w42) (i32.const 7)) (i32.rotr (get_local $w42) (i32.const 18))) (i32.shr_u (get_local $w42) (i32.const 3))) (get_local $w41))))
                (set_local $w58 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w56) (i32.const 17)) (i32.rotr (get_local $w56) (i32.const 19))) (i32.shr_u (get_local $w56) (i32.const 10))) (get_local $w51)) (i32.xor (i32.xor (i32.rotr (get_local $w43) (i32.const 7)) (i32.rotr (get_local $w43) (i32.const 18))) (i32.shr_u (get_local $w43) (i32.const 3))) (get_local $w42))))
                (set_local $w59 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w57) (i32.const 17)) (i32.rotr (get_local $w57) (i32.const 19))) (i32.shr_u (get_local $w57) (i32.const 10))) (get_local $w52)) (i32.xor (i32.xor (i32.rotr (get_local $w44) (i32.const 7)) (i32.rotr (get_local $w44) (i32.const 18))) (i32.shr_u (get_local $w44) (i32.const 3))) (get_local $w43))))
                (set_local $w60 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w58) (i32.const 17)) (i32.rotr (get_local $w58) (i32.const 19))) (i32.shr_u (get_local $w58) (i32.const 10))) (get_local $w53)) (i32.xor (i32.xor (i32.rotr (get_local $w45) (i32.const 7)) (i32.rotr (get_local $w45) (i32.const 18))) (i32.shr_u (get_local $w45) (i32.const 3))) (get_local $w44))))
                (set_local $w61 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w59) (i32.const 17)) (i32.rotr (get_local $w59) (i32.const 19))) (i32.shr_u (get_local $w59) (i32.const 10))) (get_local $w54)) (i32.xor (i32.xor (i32.rotr (get_local $w46) (i32.const 7)) (i32.rotr (get_local $w46) (i32.const 18))) (i32.shr_u (get_local $w46) (i32.const 3))) (get_local $w45))))
                (set_local $w62 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w60) (i32.const 17)) (i32.rotr (get_local $w60) (i32.const 19))) (i32.shr_u (get_local $w60) (i32.const 10))) (get_local $w55)) (i32.xor (i32.xor (i32.rotr (get_local $w47) (i32.const 7)) (i32.rotr (get_local $w47) (i32.const 18))) (i32.shr_u (get_local $w47) (i32.const 3))) (get_local $w46))))
                (set_local $w63 (i32.add (i32.add (i32.add (i32.xor (i32.xor (i32.rotr (get_local $w61) (i32.const 17)) (i32.rotr (get_local $w61) (i32.const 19))) (i32.shr_u (get_local $w61) (i32.const 10))) (get_local $w56)) (i32.xor (i32.xor (i32.rotr (get_local $w48) (i32.const 7)) (i32.rotr (get_local $w48) (i32.const 18))) (i32.shr_u (get_local $w48) (i32.const 3))) (get_local $w47))))

                ;; load previous hash state
                (set_local $a (i32.load offset=0 (get_local $ctx)))
                (set_local $b (i32.load offset=4 (get_local $ctx)))
                (set_local $c (i32.load offset=8 (get_local $ctx)))
                (set_local $d (i32.load offset=12 (get_local $ctx)))
                (set_local $e (i32.load offset=16 (get_local $ctx)))
                (set_local $f (i32.load offset=20 (get_local $ctx)))
                (set_local $g (i32.load offset=24 (get_local $ctx)))
                (set_local $h (i32.load offset=28 (get_local $ctx)))

                ;; ROUND 0

                ;; precompute intermediate values

                ;; T1 = h + big_sig1(e) + ch(e, f, g) + K0 + W0
                ;; T2 = big_sig0(a) + Maj(a, b, c)

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w0)) (get_local $k0)))
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

                ;; ROUND 1

                ;; precompute intermediate values

                ;; T1 = h + big_sig1(e) + ch(e, f, g) + K1 + W1
                ;; T2 = big_sig0(a) + Maj(a, b, c)

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w1)) (get_local $k1)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w2)) (get_local $k2)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w3)) (get_local $k3)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w4)) (get_local $k4)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w5)) (get_local $k5)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w6)) (get_local $k6)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w7)) (get_local $k7)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w8)) (get_local $k8)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w9)) (get_local $k9)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w10)) (get_local $k10)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w11)) (get_local $k11)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w12)) (get_local $k12)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w13)) (get_local $k13)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w14)) (get_local $k14)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w15)) (get_local $k15)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w16)) (get_local $k16)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w17)) (get_local $k17)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w18)) (get_local $k18)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w19)) (get_local $k19)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w20)) (get_local $k20)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w21)) (get_local $k21)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w22)) (get_local $k22)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w23)) (get_local $k23)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w24)) (get_local $k24)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w25)) (get_local $k25)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w26)) (get_local $k26)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w27)) (get_local $k27)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w28)) (get_local $k28)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w29)) (get_local $k29)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w30)) (get_local $k30)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w31)) (get_local $k31)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w32)) (get_local $k32)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w33)) (get_local $k33)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w34)) (get_local $k34)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w35)) (get_local $k35)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w36)) (get_local $k36)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w37)) (get_local $k37)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w38)) (get_local $k38)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w39)) (get_local $k39)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w40)) (get_local $k40)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w41)) (get_local $k41)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w42)) (get_local $k42)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w43)) (get_local $k43)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w44)) (get_local $k44)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w45)) (get_local $k45)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w46)) (get_local $k46)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w47)) (get_local $k47)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w48)) (get_local $k48)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w49)) (get_local $k49)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w50)) (get_local $k50)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w51)) (get_local $k51)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w52)) (get_local $k52)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w53)) (get_local $k53)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w54)) (get_local $k54)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w55)) (get_local $k55)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w56)) (get_local $k56)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w57)) (get_local $k57)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w58)) (get_local $k58)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w59)) (get_local $k59)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w60)) (get_local $k60)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w61)) (get_local $k61)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w62)) (get_local $k62)))
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

                (set_local $ch_res (i32.xor (i32.and (get_local $e) (get_local $f)) (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))))
                (set_local $maj_res (i32.xor (i32.xor (i32.and (get_local $a) (get_local $b)) (i32.and (get_local $a) (get_local $c))) (i32.and (get_local $b) (get_local $c))))
                
                (set_local $big_sig0_res (i32.xor (i32.xor (i32.rotr (get_local $a) (i32.const 2)) (i32.rotr (get_local $a) (i32.const 13))) (i32.rotr (get_local $a) (i32.const 22))))
                (set_local $big_sig1_res (i32.xor  (i32.xor (i32.rotr (get_local $e) (i32.const 6)) (i32.rotr (get_local $e) (i32.const 11))) (i32.rotr (get_local $e) (i32.const 25))))

                (set_local $T1 (i32.add (i32.add (i32.add (i32.add (get_local $h) (get_local $ch_res)) (get_local $big_sig1_res)) (get_local $w63)) (get_local $k63)))
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

                (i32.store offset=0  (get_local $ctx) (i32.add (i32.load offset=0  (get_local $ctx)) (get_local $a)))
                (i32.store offset=4  (get_local $ctx) (i32.add (i32.load offset=4  (get_local $ctx)) (get_local $b)))
                (i32.store offset=8  (get_local $ctx) (i32.add (i32.load offset=8  (get_local $ctx)) (get_local $c)))
                (i32.store offset=12 (get_local $ctx) (i32.add (i32.load offset=12 (get_local $ctx)) (get_local $d)))
                (i32.store offset=16 (get_local $ctx) (i32.add (i32.load offset=16 (get_local $ctx)) (get_local $e)))
                (i32.store offset=20 (get_local $ctx) (i32.add (i32.load offset=20 (get_local $ctx)) (get_local $f)))
                (i32.store offset=24 (get_local $ctx) (i32.add (i32.load offset=24 (get_local $ctx)) (get_local $g)))
                (i32.store offset=28 (get_local $ctx) (i32.add (i32.load offset=28 (get_local $ctx)) (get_local $h)))))


        ;; HASH COMPLETE FOR MESSAGE BLOCK

        ;; correctly store last word in the input for next update and return number of leftover bytes
        (i32.store8 (get_local $input) (i32.shr_u (get_local $last_word) (i32.const 24)))
        (i32.store8 offset=1 (get_local $input) (i32.shr_u (get_local $last_word) (i32.const 16)))
        (i32.store8 offset=2 (get_local $input) (i32.shr_u (get_local $last_word) (i32.const 8)))
        (i32.store8 offset=3 (get_local $input) (get_local $last_word))
        (get_local $leftover)))
