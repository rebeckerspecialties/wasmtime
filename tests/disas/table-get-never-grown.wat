;;! target = "x86_64"
;;! test = "optimize"
;;! flags = "-O opt-level=0"

;; A table declared with only a minimum size is nominally growable, but when it
;; is never imported, exported, or mutated its size is fixed in practice. Its
;; accesses should use a constant bound and a hoistable (readonly, can_move)
;; base, just like a table declared with `min == max` (see
;; `table-get-fixed-size.wat`).

(module
  (table 7 externref)
  (func (export "table.get.const") (result externref)
    i32.const 0
    table.get 0)
  (func (export "table.get.var") (param i32) (result externref)
    local.get 0
    table.get 0))
;; function u0:0(i64 vmctx, i64) -> i32 tail {
;;     region0 = 1342177280 "DefinedTable(StaticModuleIndex(0), DefinedTableIndex(0))"
;;     gv0 = vmctx
;;     gv1 = load.i64 notrap aligned readonly gv0+8
;;     gv2 = load.i64 notrap aligned gv1+24
;;     gv3 = vmctx
;;     gv4 = load.i64 notrap aligned readonly can_move gv3+48
;;     stack_limit = gv2
;;
;;                                 block0(v0: i64, v1: i64):
;; @0049                               v3 = iconst.i32 0
;; @004b                               v4 = iconst.i32 7
;; @004b                               v5 = icmp uge v3, v4  ; v3 = 0, v4 = 7
;; @004b                               v6 = uextend.i64 v3  ; v3 = 0
;; @004b                               v7 = load.i64 notrap aligned readonly can_move v0+48
;;                                     v13 = iconst.i64 2
;; @004b                               v8 = ishl v6, v13  ; v13 = 2
;; @004b                               v9 = iadd v7, v8
;; @004b                               v10 = iconst.i64 0
;; @004b                               v11 = select_spectre_guard v5, v10, v9  ; v10 = 0
;; @004b                               v12 = load.i32 user6 aligned region0 v11
;; @004d                               jump block1
;;
;;                                 block1:
;; @004d                               return v12
;; }
;;
;; function u0:1(i64 vmctx, i64, i32) -> i32 tail {
;;     region0 = 1342177280 "DefinedTable(StaticModuleIndex(0), DefinedTableIndex(0))"
;;     gv0 = vmctx
;;     gv1 = load.i64 notrap aligned readonly gv0+8
;;     gv2 = load.i64 notrap aligned gv1+24
;;     gv3 = vmctx
;;     gv4 = load.i64 notrap aligned readonly can_move gv3+48
;;     stack_limit = gv2
;;
;;                                 block0(v0: i64, v1: i64, v2: i32):
;; @0052                               v4 = iconst.i32 7
;; @0052                               v5 = icmp uge v2, v4  ; v4 = 7
;; @0052                               v6 = uextend.i64 v2
;; @0052                               v7 = load.i64 notrap aligned readonly can_move v0+48
;;                                     v13 = iconst.i64 2
;; @0052                               v8 = ishl v6, v13  ; v13 = 2
;; @0052                               v9 = iadd v7, v8
;; @0052                               v10 = iconst.i64 0
;; @0052                               v11 = select_spectre_guard v5, v10, v9  ; v10 = 0
;; @0052                               v12 = load.i32 user6 aligned region0 v11
;; @0054                               jump block1
;;
;;                                 block1:
;; @0054                               return v12
;; }
