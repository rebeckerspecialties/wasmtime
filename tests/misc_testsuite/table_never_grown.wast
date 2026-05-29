;;! reference_types = true

;; A table declared with only a minimum size (so nominally growable) that is
;; never imported, exported, or the target of a table mutation has a fixed size
;; in practice. Cranelift compiles its accesses with a constant bound; check
;; that in-bounds and out-of-bounds accesses still behave correctly.

(module
  (table $t 3 funcref)
  (elem (i32.const 0) $a $b $c)

  (func $a (result i32) (i32.const 10))
  (func $b (result i32) (i32.const 20))
  (func $c (result i32) (i32.const 30))

  (func (export "call") (param i32) (result i32)
    local.get 0
    call_indirect (result i32))

  (func (export "get") (param i32)
    local.get 0
    table.get $t
    drop))

;; In-bounds accesses behave as normal.
(assert_return (invoke "call" (i32.const 0)) (i32.const 10))
(assert_return (invoke "call" (i32.const 1)) (i32.const 20))
(assert_return (invoke "call" (i32.const 2)) (i32.const 30))
(assert_return (invoke "get" (i32.const 0)))
(assert_return (invoke "get" (i32.const 2)))

;; Out-of-bounds accesses still trap against the constant bound.
(assert_trap (invoke "call" (i32.const 3)) "undefined element")
(assert_trap (invoke "get" (i32.const 3)) "out of bounds table access")
(assert_trap (invoke "get" (i32.const -1)) "out of bounds table access")
