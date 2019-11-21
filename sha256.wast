(module
  (memory (export "memory") 10 1000)
    
  (func (export "sha256_init") (param $ptr i32) (param $outlen i32)
    ;; setup param block (expect memory to be cleared)
    ;; hash array 0-32
    (i32.store offset=0  (get_local $ptr) (i32.xor (i32.const 0x6a09e667) (i32.load (i32.const 0))))
    (i32.store offset=4  (get_local $ptr) (i32.xor (i32.const 0xbb67ae85) (i32.load (i32.const 4))))
    (i32.store offset=8  (get_local $ptr) (i32.xor (i32.const 0x3c6ef372) (i32.load (i32.const 8))))
    (i32.store offset=12 (get_local $ptr) (i32.xor (i32.const 0xa54ff53a) (i32.load (i32.const 12))))
    (i32.store offset=16 (get_local $ptr) (i32.xor (i32.const 0x510e527f) (i32.load (i32.const 16))))
    (i32.store offset=20 (get_local $ptr) (i32.xor (i32.const 0x9b05688c) (i32.load (i32.const 20))))
    (i32.store offset=24 (get_local $ptr) (i32.xor (i32.const 0x1f83d9ab) (i32.load (i32.const 24))))
    (i32.store offset=28 (get_local $ptr) (i32.xor (i32.const 0x5be0cd19) (i32.load (i32.const 28)))))

  (func $Ch (param $x i32) (param $y i32) (param $z i32)
    (i32.xor 
      (i32.and (get_local $x) (get_local $y))             
      (i32.and 
        (i32.xor (get_local $x) (i32.const -1))
        (get_local $y))))
 
  (func $Maj (param $x i32) (param $y i32) (param $z i32)
    (i32.xor
      (i32.xor
        (i32.and (get_local $x) (get_local $y))
        (i32.and (get_local $x) (get_local $z)))
      (i32.and (get_local $y) (get_local $z))))
  
  (func $big_sig0 (param $x i32)
    (i32.xor
      (i32.xor
        (i32.rotr (get_local $x) (i32.const 2))
        (i32.rotr (get_local $x) (i32.const 13)))
      (i32.rotr (get_local $x) (i32.const 22))))

  (func $big_sig1 (param $x i32)
    (i32.xor
      (i32.xor
        (i32.rotr (get_local $x) (i32.const 6))
        (i32.rotr (get_local $x) (i32.const 11)))
      (i32.rotr (get_local $x) (i32.const 25))))

  (func $sig0 (param $x i32)
    (i32.xor
      (i32.xor
        (i32.rotr (get_local $x) (i32.const 7))
        (i32.rotr (get_local $x) (i32.const 18)))
      (i32.rotr (get_local $x) (i32.const 3))))

  (func $sig1 (param $x i32)
    (i32.xor
      (i32.xor
        (i32.rotr (get_local $x) (i32.const 17))
        (i32.rotr (get_local $x) (i32.const 19)))
      (i32.shr_u (get_local $x) (i32.const 10))))

  (func $expand (export "expand") (param $inputPtr i32)
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

    (set_local $ctr (i32.const 0))

    (set_local $w0 (i32.load (i32.add (get_local $inputStart) (i32.const 0))))
    (set_local $w1 (i32.load (i32.add (get_local $inputStart) (i32.const 4))))
    (set_local $w2 (i32.load (i32.add (get_local $inputStart) (i32.const 8))))
    (set_local $w3 (i32.load (i32.add (get_local $inputStart) (i32.const 12))))
    (set_local $w4 (i32.load (i32.add (get_local $inputStart) (i32.const 16))))
    (set_local $w5 (i32.load (i32.add (get_local $inputStart) (i32.const 20))))
    (set_local $w6 (i32.load (i32.add (get_local $inputStart) (i32.const 24))))
    (set_local $w7 (i32.load (i32.add (get_local $inputStart) (i32.const 28))))
    (set_local $w8 (i32.load (i32.add (get_local $inputStart) (i32.const 32))))
    (set_local $w9 (i32.load (i32.add (get_local $inputStart) (i32.const 36))))
    (set_local $w10 (i32.load (i32.add (get_local $inputStart) (i32.const 40))))
    (set_local $w11 (i32.load (i32.add (get_local $inputStart) (i32.const 44))))
    (set_local $w12 (i32.load (i32.add (get_local $inputStart) (i32.const 48))))
    (set_local $w13 (i32.load (i32.add (get_local $inputStart) (i32.const 52))))
    (set_local $w14 (i32.load (i32.add (get_local $inputStart) (i32.const 56))))
    (set_local $w15 (i32.load (i32.add (get_local $inputStart) (i32.const 60))))
    
    ;; words 16-63 are defined by w[j] <- sig1(w[j-2]) + w[j-7] + sig0(w[j-15]) + w[j-16]
    (set_local $w16 (i32.add (i32.add (call $sig1 (get_local $w14)) (get_local $w9)) (i32.add (call $sig0 (get_local $w1)) (get_local $w0))))
    (set_local $w17 (i32.add (i32.add (call $sig1 (get_local $w15)) (get_local $w10)) (i32.add (call $sig0 (get_local $w2)) (get_local $w1))))
    (set_local $w18 (i32.add (i32.add (call $sig1 (get_local $w16)) (get_local $w11)) (i32.add (call $sig0 (get_local $w3)) (get_local $w2))))
    (set_local $w19 (i32.add (i32.add (call $sig1 (get_local $w17)) (get_local $w12)) (i32.add (call $sig0 (get_local $w4)) (get_local $w3))))
    (set_local $w20 (i32.add (i32.add (call $sig1 (get_local $w18)) (get_local $w13)) (i32.add (call $sig0 (get_local $w5)) (get_local $w4))))
    (set_local $w21 (i32.add (i32.add (call $sig1 (get_local $w19)) (get_local $w14)) (i32.add (call $sig0 (get_local $w6)) (get_local $w5))))
    (set_local $w22 (i32.add (i32.add (call $sig1 (get_local $w20)) (get_local $w15)) (i32.add (call $sig0 (get_local $w7)) (get_local $w6))))
    (set_local $w23 (i32.add (i32.add (call $sig1 (get_local $w21)) (get_local $w16)) (i32.add (call $sig0 (get_local $w8)) (get_local $w7))))
    (set_local $w24 (i32.add (i32.add (call $sig1 (get_local $w22)) (get_local $w17)) (i32.add (call $sig0 (get_local $w9)) (get_local $w8))))
    (set_local $w25 (i32.add (i32.add (call $sig1 (get_local $w23)) (get_local $w18)) (i32.add (call $sig0 (get_local $w10)) (get_local $w9))))
    (set_local $w26 (i32.add (i32.add (call $sig1 (get_local $w24)) (get_local $w19)) (i32.add (call $sig0 (get_local $w11)) (get_local $w10))))
    (set_local $w27 (i32.add (i32.add (call $sig1 (get_local $w25)) (get_local $w20)) (i32.add (call $sig0 (get_local $w12)) (get_local $w11))))
    (set_local $w28 (i32.add (i32.add (call $sig1 (get_local $w26)) (get_local $w21)) (i32.add (call $sig0 (get_local $w13)) (get_local $w12))))
    (set_local $w29 (i32.add (i32.add (call $sig1 (get_local $w27)) (get_local $w22)) (i32.add (call $sig0 (get_local $w14)) (get_local $w13))))
    (set_local $w30 (i32.add (i32.add (call $sig1 (get_local $w28)) (get_local $w23)) (i32.add (call $sig0 (get_local $w15)) (get_local $w14))))
    (set_local $w31 (i32.add (i32.add (call $sig1 (get_local $w29)) (get_local $w24)) (i32.add (call $sig0 (get_local $w16)) (get_local $w15))))
    (set_local $w32 (i32.add (i32.add (call $sig1 (get_local $w30)) (get_local $w25)) (i32.add (call $sig0 (get_local $w17)) (get_local $w16))))
    (set_local $w33 (i32.add (i32.add (call $sig1 (get_local $w31)) (get_local $w26)) (i32.add (call $sig0 (get_local $w18)) (get_local $w17))))
    (set_local $w34 (i32.add (i32.add (call $sig1 (get_local $w32)) (get_local $w27)) (i32.add (call $sig0 (get_local $w19)) (get_local $w18))))
    (set_local $w35 (i32.add (i32.add (call $sig1 (get_local $w33)) (get_local $w28)) (i32.add (call $sig0 (get_local $w20)) (get_local $w19))))
    (set_local $w36 (i32.add (i32.add (call $sig1 (get_local $w34)) (get_local $w29)) (i32.add (call $sig0 (get_local $w21)) (get_local $w20))))
    (set_local $w37 (i32.add (i32.add (call $sig1 (get_local $w35)) (get_local $w30)) (i32.add (call $sig0 (get_local $w22)) (get_local $w21))))
    (set_local $w38 (i32.add (i32.add (call $sig1 (get_local $w36)) (get_local $w31)) (i32.add (call $sig0 (get_local $w23)) (get_local $w22))))
    (set_local $w39 (i32.add (i32.add (call $sig1 (get_local $w37)) (get_local $w32)) (i32.add (call $sig0 (get_local $w24)) (get_local $w23))))
    (set_local $w40 (i32.add (i32.add (call $sig1 (get_local $w38)) (get_local $w33)) (i32.add (call $sig0 (get_local $w25)) (get_local $w24))))
    (set_local $w41 (i32.add (i32.add (call $sig1 (get_local $w39)) (get_local $w34)) (i32.add (call $sig0 (get_local $w26)) (get_local $w25))))
    (set_local $w42 (i32.add (i32.add (call $sig1 (get_local $w40)) (get_local $w35)) (i32.add (call $sig0 (get_local $w27)) (get_local $w26))))
    (set_local $w43 (i32.add (i32.add (call $sig1 (get_local $w41)) (get_local $w36)) (i32.add (call $sig0 (get_local $w28)) (get_local $w27))))
    (set_local $w44 (i32.add (i32.add (call $sig1 (get_local $w42)) (get_local $w37)) (i32.add (call $sig0 (get_local $w29)) (get_local $w28))))
    (set_local $w45 (i32.add (i32.add (call $sig1 (get_local $w43)) (get_local $w38)) (i32.add (call $sig0 (get_local $w30)) (get_local $w29))))
    (set_local $w46 (i32.add (i32.add (call $sig1 (get_local $w44)) (get_local $w39)) (i32.add (call $sig0 (get_local $w31)) (get_local $w30))))
    (set_local $w47 (i32.add (i32.add (call $sig1 (get_local $w45)) (get_local $w40)) (i32.add (call $sig0 (get_local $w32)) (get_local $w31))))
    (set_local $w48 (i32.add (i32.add (call $sig1 (get_local $w46)) (get_local $w41)) (i32.add (call $sig0 (get_local $w33)) (get_local $w32))))
    (set_local $w49 (i32.add (i32.add (call $sig1 (get_local $w47)) (get_local $w42)) (i32.add (call $sig0 (get_local $w34)) (get_local $w33))))
    (set_local $w50 (i32.add (i32.add (call $sig1 (get_local $w48)) (get_local $w43)) (i32.add (call $sig0 (get_local $w35)) (get_local $w34))))
    (set_local $w51 (i32.add (i32.add (call $sig1 (get_local $w49)) (get_local $w44)) (i32.add (call $sig0 (get_local $w36)) (get_local $w35))))
    (set_local $w52 (i32.add (i32.add (call $sig1 (get_local $w50)) (get_local $w45)) (i32.add (call $sig0 (get_local $w37)) (get_local $w36))))
    (set_local $w53 (i32.add (i32.add (call $sig1 (get_local $w51)) (get_local $w46)) (i32.add (call $sig0 (get_local $w38)) (get_local $w37))))
    (set_local $w54 (i32.add (i32.add (call $sig1 (get_local $w52)) (get_local $w47)) (i32.add (call $sig0 (get_local $w39)) (get_local $w38))))
    (set_local $w55 (i32.add (i32.add (call $sig1 (get_local $w53)) (get_local $w48)) (i32.add (call $sig0 (get_local $w40)) (get_local $w39))))
    (set_local $w56 (i32.add (i32.add (call $sig1 (get_local $w54)) (get_local $w49)) (i32.add (call $sig0 (get_local $w41)) (get_local $w40))))
    (set_local $w57 (i32.add (i32.add (call $sig1 (get_local $w55)) (get_local $w50)) (i32.add (call $sig0 (get_local $w42)) (get_local $w41))))
    (set_local $w58 (i32.add (i32.add (call $sig1 (get_local $w56)) (get_local $w51)) (i32.add (call $sig0 (get_local $w43)) (get_local $w42))))
    (set_local $w59 (i32.add (i32.add (call $sig1 (get_local $w57)) (get_local $w52)) (i32.add (call $sig0 (get_local $w44)) (get_local $w43))))
    (set_local $w60 (i32.add (i32.add (call $sig1 (get_local $w58)) (get_local $w53)) (i32.add (call $sig0 (get_local $w45)) (get_local $w44))))
    (set_local $w61 (i32.add (i32.add (call $sig1 (get_local $w59)) (get_local $w54)) (i32.add (call $sig0 (get_local $w46)) (get_local $w45))))
    (set_local $w62 (i32.add (i32.add (call $sig1 (get_local $w60)) (get_local $w55)) (i32.add (call $sig0 (get_local $w47)) (get_local $w46))))
    (set_local $w63 (i32.add (i32.add (call $sig1 (get_local $w61)) (get_local $w56)) (i32.add (call $sig0 (get_local $w48)) (get_local $w47)))))

    ;; (set_local $w16 (i32.add (i32.add (i32.add (call $sig1 (get_local $w14)) (get_local $w9)) (call $sig0 (get_local $w1))) (get_local $w0)))
    ;; (set_local $w17 (i32.add (i32.add (i32.add (call $sig1 (get_local $w15)) (get_local $w10)) (call $sig0 (get_local $w2))) (get_local $w1)))
    ;; (set_local $w18 (i32.add (i32.add (i32.add (call $sig1 (get_local $w16)) (get_local $w11)) (call $sig0 (get_local $w3))) (get_local $w2)))
    ;; (set_local $w19 (i32.add (i32.add (i32.add (call $sig1 (get_local $w17)) (get_local $w12)) (call $sig0 (get_local $w4))) (get_local $w3)))
    ;; (set_local $w20 (i32.add (i32.add (i32.add (call $sig1 (get_local $w18)) (get_local $w13)) (call $sig0 (get_local $w5))) (get_local $w4)))
    ;; (set_local $w21 (i32.add (i32.add (i32.add (call $sig1 (get_local $w19)) (get_local $w14)) (call $sig0 (get_local $w6))) (get_local $w5)))
    ;; (set_local $w22 (i32.add (i32.add (i32.add (call $sig1 (get_local $w20)) (get_local $w15)) (call $sig0 (get_local $w7))) (get_local $w6)))
    ;; (set_local $w23 (i32.add (i32.add (i32.add (call $sig1 (get_local $w21)) (get_local $w16)) (call $sig0 (get_local $w8))) (get_local $w7)))
    ;; (set_local $w24 (i32.add (i32.add (i32.add (call $sig1 (get_local $w22)) (get_local $w17)) (call $sig0 (get_local $w9))) (get_local $w8)))
    ;; (set_local $w25 (i32.add (i32.add (i32.add (call $sig1 (get_local $w23)) (get_local $w18)) (call $sig0 (get_local $w10))) (get_local $w9)))
    ;; (set_local $w26 (i32.add (i32.add (i32.add (call $sig1 (get_local $w24)) (get_local $w19)) (call $sig0 (get_local $w11))) (get_local $w10)))
    ;; (set_local $w27 (i32.add (i32.add (i32.add (call $sig1 (get_local $w25)) (get_local $w20)) (call $sig0 (get_local $w12))) (get_local $w11)))
    ;; (set_local $w28 (i32.add (i32.add (i32.add (call $sig1 (get_local $w26)) (get_local $w21)) (call $sig0 (get_local $w13))) (get_local $w12)))
    ;; (set_local $w29 (i32.add (i32.add (i32.add (call $sig1 (get_local $w27)) (get_local $w22)) (call $sig0 (get_local $w14))) (get_local $w13)))
    ;; (set_local $w30 (i32.add (i32.add (i32.add (call $sig1 (get_local $w28)) (get_local $w23)) (call $sig0 (get_local $w15))) (get_local $w14)))
    ;; (set_local $w31 (i32.add (i32.add (i32.add (call $sig1 (get_local $w29)) (get_local $w24)) (call $sig0 (get_local $w16))) (get_local $w15)))
    ;; (set_local $w32 (i32.add (i32.add (i32.add (call $sig1 (get_local $w30)) (get_local $w25)) (call $sig0 (get_local $w17))) (get_local $w16)))
    ;; (set_local $w33 (i32.add (i32.add (i32.add (call $sig1 (get_local $w31)) (get_local $w26)) (call $sig0 (get_local $w18))) (get_local $w17)))
    ;; (set_local $w34 (i32.add (i32.add (i32.add (call $sig1 (get_local $w32)) (get_local $w27)) (call $sig0 (get_local $w19))) (get_local $w18)))
    ;; (set_local $w35 (i32.add (i32.add (i32.add (call $sig1 (get_local $w33)) (get_local $w28)) (call $sig0 (get_local $w20))) (get_local $w19)))
    ;; (set_local $w36 (i32.add (i32.add (i32.add (call $sig1 (get_local $w34)) (get_local $w29)) (call $sig0 (get_local $w21))) (get_local $w20)))
    ;; (set_local $w37 (i32.add (i32.add (i32.add (call $sig1 (get_local $w35)) (get_local $w30)) (call $sig0 (get_local $w22))) (get_local $w21)))
    ;; (set_local $w38 (i32.add (i32.add (i32.add (call $sig1 (get_local $w36)) (get_local $w31)) (call $sig0 (get_local $w23))) (get_local $w22)))
    ;; (set_local $w39 (i32.add (i32.add (i32.add (call $sig1 (get_local $w37)) (get_local $w32)) (call $sig0 (get_local $w24))) (get_local $w23)))
    ;; (set_local $w40 (i32.add (i32.add (i32.add (call $sig1 (get_local $w38)) (get_local $w33)) (call $sig0 (get_local $w25))) (get_local $w24)))
    ;; (set_local $w41 (i32.add (i32.add (i32.add (call $sig1 (get_local $w39)) (get_local $w34)) (call $sig0 (get_local $w26))) (get_local $w25)))
    ;; (set_local $w42 (i32.add (i32.add (i32.add (call $sig1 (get_local $w40)) (get_local $w35)) (call $sig0 (get_local $w27))) (get_local $w26)))
    ;; (set_local $w43 (i32.add (i32.add (i32.add (call $sig1 (get_local $w41)) (get_local $w36)) (call $sig0 (get_local $w28))) (get_local $w27)))
    ;; (set_local $w44 (i32.add (i32.add (i32.add (call $sig1 (get_local $w42)) (get_local $w37)) (call $sig0 (get_local $w29))) (get_local $w28)))
    ;; (set_local $w45 (i32.add (i32.add (i32.add (call $sig1 (get_local $w43)) (get_local $w38)) (call $sig0 (get_local $w30))) (get_local $w29)))
    ;; (set_local $w46 (i32.add (i32.add (i32.add (call $sig1 (get_local $w44)) (get_local $w39)) (call $sig0 (get_local $w31))) (get_local $w30)))
    ;; (set_local $w47 (i32.add (i32.add (i32.add (call $sig1 (get_local $w45)) (get_local $w40)) (call $sig0 (get_local $w32))) (get_local $w31)))
    ;; (set_local $w48 (i32.add (i32.add (i32.add (call $sig1 (get_local $w46)) (get_local $w41)) (call $sig0 (get_local $w33))) (get_local $w32)))
    ;; (set_local $w49 (i32.add (i32.add (i32.add (call $sig1 (get_local $w47)) (get_local $w42)) (call $sig0 (get_local $w34))) (get_local $w33)))
    ;; (set_local $w50 (i32.add (i32.add (i32.add (call $sig1 (get_local $w48)) (get_local $w43)) (call $sig0 (get_local $w35))) (get_local $w34)))
    ;; (set_local $w51 (i32.add (i32.add (i32.add (call $sig1 (get_local $w49)) (get_local $w44)) (call $sig0 (get_local $w36))) (get_local $w35)))
    ;; (set_local $w52 (i32.add (i32.add (i32.add (call $sig1 (get_local $w50)) (get_local $w45)) (call $sig0 (get_local $w37))) (get_local $w36)))
    ;; (set_local $w53 (i32.add (i32.add (i32.add (call $sig1 (get_local $w51)) (get_local $w46)) (call $sig0 (get_local $w38))) (get_local $w37)))
    ;; (set_local $w54 (i32.add (i32.add (i32.add (call $sig1 (get_local $w52)) (get_local $w47)) (call $sig0 (get_local $w39))) (get_local $w38)))
    ;; (set_local $w55 (i32.add (i32.add (i32.add (call $sig1 (get_local $w53)) (get_local $w48)) (call $sig0 (get_local $w40))) (get_local $w39)))
    ;; (set_local $w56 (i32.add (i32.add (i32.add (call $sig1 (get_local $w54)) (get_local $w49)) (call $sig0 (get_local $w41))) (get_local $w40)))
    ;; (set_local $w57 (i32.add (i32.add (i32.add (call $sig1 (get_local $w55)) (get_local $w50)) (call $sig0 (get_local $w42))) (get_local $w41)))
    ;; (set_local $w58 (i32.add (i32.add (i32.add (call $sig1 (get_local $w56)) (get_local $w51)) (call $sig0 (get_local $w43))) (get_local $w42)))
    ;; (set_local $w59 (i32.add (i32.add (i32.add (call $sig1 (get_local $w57)) (get_local $w52)) (call $sig0 (get_local $w44))) (get_local $w43)))
    ;; (set_local $w60 (i32.add (i32.add (i32.add (call $sig1 (get_local $w58)) (get_local $w53)) (call $sig0 (get_local $w45))) (get_local $w44)))
    ;; (set_local $w61 (i32.add (i32.add (i32.add (call $sig1 (get_local $w59)) (get_local $w54)) (call $sig0 (get_local $w46))) (get_local $w45)))
    ;; (set_local $w62 (i32.add (i32.add (i32.add (call $sig1 (get_local $w60)) (get_local $w55)) (call $sig0 (get_local $w47))) (get_local $w46)))
    ;; (set_local $w63 (i32.add (i32.add (i32.add (call $sig1 (get_local $w61)) (get_local $w56)) (call $sig0 (get_local $w48))) (get_local $w47)))))
            
  ;; (func $sha256_compress (export "sha256_compress") (param $)))

  (func $update (export "update") (param $ptr i32)
    (local $r0 i32)
    (local $r1 i32)
    (local $r2 i32)
    (local $r3 i32)
    (local $r4 i32)
    (local $r5 i32)
    (local $r6 i32)
    (local $r7 i32)

    (local $T1 i32)
    (local $T2 i32)

    (local $ch_res i32)
    (local $maj_res i32)
    (local $big_sig0_res i32)
    (local $big_sig1_res i32)

    (set_local $r0 (i32.load (i32.add (get_local $ptr) (i32.const 0))))
    (set_local $r1 (i32.load (i32.add (get_local $ptr) (i32.const 4))))
    (set_local $r2 (i32.load (i32.add (get_local $ptr) (i32.const 8))))
    (set_local $r3 (i32.load (i32.add (get_local $ptr) (i32.const 12))))
    (set_local $r4 (i32.load (i32.add (get_local $ptr) (i32.const 16))))
    (set_local $r5 (i32.load (i32.add (get_local $ptr) (i32.const 20))))
    (set_local $r6 (i32.load (i32.add (get_local $ptr) (i32.const 24))))
    (set_local $r7 (i32.load (i32.add (get_local $ptr) (i32.const 28))))
    

    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    ;; round 0

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K0) (get_local $w0))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 1

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K1) (get_local $w1))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 2

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K2) (get_local $w2))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 3

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K3) (get_local $w3))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 4

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K4) (get_local $w4))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 5

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K5) (get_local $w5))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 6

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K6) (get_local $w6))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

     ;; round 7

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K7) (get_local $w7))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

     ;; round 8

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K8) (get_local $w8))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

     ;; round 9

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K9) (get_local $w9))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 10

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K10) (get_local $w10))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 11

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K11) (get_local $w11))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 12

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K12) (get_local $w12))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 13

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K13) (get_local $w13))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 14

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K14) (get_local $w14))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 15

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K15) (get_local $w15))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 16

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K16) (get_local $w16))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 17

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K17) (get_local $w17))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 18

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K18) (get_local $w18))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 19

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K19) (get_local $w19))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 20

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K20) (get_local $w20))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 21

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K21) (get_local $w21))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 22

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K22) (get_local $w22))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 23

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K23) (get_local $w23))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 24

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K24) (get_local $w24))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 25

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K25) (get_local $w25))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 26

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K26) (get_local $w26))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 27

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K27) (get_local $w27))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 28

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K28) (get_local $w28))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 29

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K29) (get_local $w29))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 30

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K30) (get_local $w30))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 31

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K31) (get_local $w31))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 32

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K32) (get_local $w32))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 33

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K33) (get_local $w33))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 34

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K34) (get_local $w34))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 35

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K35) (get_local $w35))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 36

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K36) (get_local $w36))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 37

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K37) (get_local $w37))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 38

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K38) (get_local $w38))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 39

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K39) (get_local $w39))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 40

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K40) (get_local $w40))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 41

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K41) (get_local $w41))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 42

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K42) (get_local $w42))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 43

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K43) (get_local $w43))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 44

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K44) (get_local $w44))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 45

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K45) (get_local $w45))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 46

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K46) (get_local $w46))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 47

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K47) (get_local $w47))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 48

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K48) (get_local $w48))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 49

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K49) (get_local $w49))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 50

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K50) (get_local $w50))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 51

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K51) (get_local $w51))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 52

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K52) (get_local $w52))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 53

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K53) (get_local $w53))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 54

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K54) (get_local $w54))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 55

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K55) (get_local $w55))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 56

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K56) (get_local $w56))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 57

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K57) (get_local $w57))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 58

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K58) (get_local $w58))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 59

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K59) (get_local $w59))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 60

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K60) (get_local $w60))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 61

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K61) (get_local $w61))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 62

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K62) (get_local $w62))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
    (set_local $r0 (i32.add (get_local $T1) (get_local $T2)))

    ;; round 63

    ;; precompute intermediate values
    (set_local $ch_res (call $Ch (get_local $r4) (get_local $r5) (get_local $r6)))
    (set_local $maj_res (call $Maj (get_local $r0) (get_local $r1) (get_local $r2)))
    (set_local $big_sig0_res (call $big_sig0 (get_local $0)))
    (set_local $big_sig1_res (call $big_sig1 (get_local $4)))

    (set_local $T1 (i32.add (i32.add (get_local $r7) (get_local $big_sig1_res)) (i32.add (get_local $K63) (get_local $w63))))
    (set_local $T2 (i32.add (get_local $big_sig0_res) (get_local $maj_res)))

    ;; update registers
    (set_local $r7 (get_local $r6))  
    (set_local $r6 (get_local $r5))  
    (set_local $r5 (get_local $r4))  
    (set_local $r4 (i32.add (get_local $r3) (get_local $T1)))

    (set_local $r3 (get_local $r2))  
    (set_local $r2 (get_local $r1))  
    (set_local $r1 (get_local $r0))  
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
