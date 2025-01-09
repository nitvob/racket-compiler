#lang racket
(provide interp)
(provide interp-env)
(provide interp-match-pat)
(require "ast.rkt")
(require "interp-prim.rkt")

;; type Value =
;; | Integer
;; | Boolean
;; | Character
;; | Eof
;; | Void
;; | '()
;; | (cons Value Value)
;; | (box Value)
;; | (string Character ...)
;; | (vector Value ...)

;; type Env = (Listof (List Id Value))
;; Prog -> Answer
(define (interp p)
  (match p
    [(Prog ds e)
     (interp-env e '() ds)]))

;; Expr Env -> Answer
(define (interp-env e r ds)
  (match e
    [(Lit d) d]
    [(Eof)   eof]
    [(Var x) (lookup r x)]
    [(Prim0 p) (interp-prim0 p)]
    [(Prim1 p e)
     (match (interp-env e r ds)
       ['err 'err]
       [v (interp-prim1 p v)])]
    [(Prim2 p e1 e2)
     (match (interp-env e1 r ds)
       ['err 'err]
       [v1 (match (interp-env e2 r ds)
             ['err 'err]
             [v2 (interp-prim2 p v1 v2)])])]
    [(Prim3 p e1 e2 e3)
     (match (interp-env e1 r ds)
       ['err 'err]
       [v1 (match (interp-env e2 r ds)
             ['err 'err]
             [v2 (match (interp-env e3 r ds)
                   ['err 'err]
                   [v3 (interp-prim3 p v1 v2 v3)])])])]
    [(PrimN p es)
     (match (interp-env* es r ds)
       ['err 'err]
       [vs (interp-primN p vs)])]
    [(If e0 e1 e2)
     (match (interp-env e0 r ds)
       ['err 'err]
       [v
        (if v
            (interp-env e1 r ds)
            (interp-env e2 r ds))])]
    [(Begin e1 e2)
     (match (interp-env e1 r ds)
       ['err 'err]
       [v    (interp-env e2 r ds)])]
    [(Let x e1 e2)
     (match (interp-env e1 r ds)
       ['err 'err]
       [v (interp-env e2 (ext r x v) ds)])]
    [(App f es)
     (match (interp-env* es r ds)
       ['err 'err]
       [vs
        (match (defns-lookup ds f)
          [(Defn f xs e)
           ; check arity matches
           (if (= (length xs) (length vs))
               (interp-env e (zip xs vs) ds)
               'err)])])]     
    [(Match e ps es)
     (match (interp-env e r ds)
       ['err 'err]
       [v
        (interp-match v ps es r ds)])]))       

;; (Listof Expr) REnv Defns -> (Listof Value) | 'err
(define (interp-env* es r ds)
  (match es
    ['() '()]
    [(cons e es)
     (match (interp-env e r ds)
       ['err 'err]
       [v (match (interp-env* es r ds)
            ['err 'err]
            [vs (cons v vs)])])]))

;; Value [Listof Pat] [Listof Expr] Env Defns -> Answer
(define (interp-match v ps es r ds)
  (match* (ps es)
    [('() '()) 'err]
    [((cons p ps) (cons e es))
     (match (interp-match-pat p v r ds)
       [#f (interp-match v ps es r ds)]
       ['err 'err]
       [r  (interp-env e r ds)])]))

;; Pat Value Env Defns -> [Maybe Env] | 'err
(define (interp-match-pat p v r ds)
  (match p
    [(Var '_) r]
    [(Var x) (ext r x v)]
    [(Lit l) (and (eqv? l v) r)]
    [(Box p)
     (match v
       [(box v)
        (interp-match-pat p v r ds)]
       [_ #f])]
    [(Cons p1 p2)
     (match v
       [(cons v1 v2)
        (match (interp-match-pat p1 v1 r ds)
          [#f #f]
          ['err 'err]
          [r1 (interp-match-pat p2 v2 r1 ds)])]
       [_ #f])]
    [(Conj p1 p2)
     (match (interp-match-pat p1 v r ds)
       [#f #f]
       ['err 'err]
       [r1 (interp-match-pat p2 v r1 ds)])]
    [(List ps)     
     (interp-match-pat-list ps v r ds)]
    [(Vect ps)
     (and (vector? v)
          (= (vector-length v) (length ps))
          (interp-match-pat-vector ps v 0 r ds))]
    [(Pred f)
     (match (defns-lookup ds f)
       [(Defn f xs e)
        (match xs
          [(list x)
           (match (interp-env e (list (list x v)) ds)
             [#f #f]
             ['err 'err]
             [_ r])]
          [_ 'err])])]))
        
;; [Listof Pat] Value Env Defns -> [Maybe Env] | 'err
(define (interp-match-pat-list ps v r ds)
  (match ps
    ['()
     (match v
       ['() r]
       [_ #f])]
    [(cons p ps)
     (match v
       [(cons v vs)
        (match (interp-match-pat p v r ds)
          [#f #f]
          ['err 'err]
          [r1 (interp-match-pat-list ps vs r1 ds)])]
       [_ #f])]))

;; [Listof Pat] Value Nat Env Defns -> [Maybe Env] | 'err
(define (interp-match-pat-vector ps v i r ds)
  (match ps
    ['() r]
    [(cons p ps)
     (match (interp-match-pat p (vector-ref v i) r ds)
       [#f #f]
       ['err 'err]
       [r1 (interp-match-pat-vector ps v (add1 i) r1 ds)])]))

;; Defns Symbol -> Defn
(define (defns-lookup ds f)
  (findf (match-lambda [(Defn g _ _) (eq? f g)])
         ds))

(define (zip xs ys)
  (match* (xs ys)
    [('() '()) '()]
    [((cons x xs) (cons y ys))
     (cons (list x y)
           (zip xs ys))]))

;; Env Id -> Value
(define (lookup r x)
  (match r
    [(cons (list y val) r)
     (if (symbol=? x y)
         val
         (lookup r x))]))

;; Env Id Value -> Env
(define (ext r x v)
  (cons (list x v) r))

