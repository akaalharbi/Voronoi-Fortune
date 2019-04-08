From mathcomp Require Import all_ssreflect all_algebra all_field.


Import GRing.Theory Num.Theory Num.ExtraDef.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.



Section ab1.

Variable R : rcfType.

Open Scope ring_scope.

(*       Typical examples of elements in R        *)
Check ((-12%:~R/17%:R) : R )==  ((-12%:R/17%:R) : R).
(* Eval compute in (-12%:~R/17%:R) . *)

(* Eval compute in ((-12%:~R/17%:R) : R ). *)
(* Eval compute in ((-12%:R/17%:R) : R )==  ((-12%:R/17%:R) : R). *)
(*                                                                           *)
(*****************************************************************************)
(* This file contains an implementation of Fortune's algorithm which follows *)
(* closely the file `python/fortun.py`.                                      *)
(* Data structures:                                                          *)
(* - Point P == (P.x , P.y)                                                  *)
(* - Arc   C == (Point, bool) | Null. `bool` is a flag to a circle event.    *)
(*               while Null is an empty arc                                  *)
(* - Beachline ==  seq Arc. The arcs in the beachline are ordered according  *)
(*                          to their occurrences according to the x-axis.    *)
(* - Edge (p_l p_r start final : Point) ( complete :bool)  ==                *)
(*   + p_l p_r are the two focal points that seperated by the edge.          *)
(*   + start & end are the end points of the edge. End may not be known,     *)
(*                                                 its default value is (0,0)*)
(*   + complete indicates that the end has been discovered.                  *)
(* - Edges == seq Edge. Not ordered                                          *)
(* - Priority Queue TODO                                                     *)
(*   + Basic idea:implement it as a Record that contains a list and an insert*)
(*     and delete functions. For insert/delete we look for max/min elemnt's  *)
(*     index then create a new list. Also, we need a check fun               *)
(* - Sweepline is defined implicitly and it moves from bottom to top.        *)
(* - Indices range from 1 to n in contrast to the pythonic convention        *)
(*****************************************************************************)


(* TODO get rid of `Record` and use `Definition` instead for automatic inheritance *) 
Record point     : Type := Point { x :  R ;  y    : R }.
Record arc       : Type := Arc   { p : point; circle : bool}.
Record beachline : Type := Beachline { B : seq arc}.
Record edge      : Type := Edge  {
  s_l   :  point ; (* Site left/*)
  s_r   :  point ; (*/Site right*)
  start :  point ;   
  final :  point ;   
  complete: bool ;               }.

Eval compute in drop 3 [:: 1; 2; 4; 3; 5; 3]%nat.

(* In the case of a circle event we need to know the left and the right arcs.*)
(* Else, we only need p and the fact that it's not a circle event. We assign *)
(* the default value (0, 0) to  p_l and p_r in case of a site event.         *)
(* y indicates where the event will occur, e.g. for a site event y == p.(y)  *)
Record event      : Type := Event {
  p_l  :    point ; (* arc left /*)
  p_m  :    point ; (* Disappearing arc *)
  p_r  :    point ; (*/arc right *)
  sweepline :   R ;               }.




Record PQueue  : Type := Equip { 
   s   : seq event;
  push : event -> seq event ; (* It implicitly acts on a given seq e.g. s *)
  pop  : event  * seq event ; (* Highest priority element *)
  del  : event -> seq event ;
  is_empty : seq event -> bool     ;
                                   }.
(* Order functions TODO put an apporpiate scope without messing other orders! *)
Definition geq (p1 p2 : point ) : bool := 
  if p1.(y) >= p2.(y) then true 
  else if (p1.(y) == p2.(y)) &&  (p1.(x) >= p2.(x)) then true 
  else false.
  
Definition less (p1 p2 : point) : bool := 
  if geq p1 p2 then false else true.

Fixpoint insert ( s : seq event) (e : event)  := 
  match s with 
  | [::] => [:: e]
  | h::t =>  if  (geq h.(p_m)  e.(p_m)) then (* The y-coordinate of the site *)
              e :: h :: t
            else insert t e
  end.


(* Dummy event *)
Definition nul_ev := Event (Point 1%:R 2%:R) (Point 1%:R 2%:R) 
                              (Point 1%:R 2%:R) 2%:R.

(* TODO define equality for events!  *)
Definition delete  ( s : seq event) ( e : event )  := s (* rem e s TODO*). 
Definition pop_elm ( s : seq event) := ( head nul_ev s, drop 1 s).
Definition empty   ( s : seq event) := if size s is 0 then true else false.

Check pop_elm.

(* Primitve Priority Queue *)
Definition prique  (s : seq event) : PQueue := Equip s (insert s)
                                                 (pop_elm s) (delete s) empty.
Check prique.


(* We need to keep track of beachline, edges, and events  *)
(* Record track : Type := Track { ent : event; bch : beachline; edg : seq edge;
                                q  : PQueue }.*)
                                
(*---------------------------- Searching lists ------------------------------*)
(* - Check the seq.v from mathcomp *)

Check  x (Point 1%:R 2%:R).


(* Definition circumcenter  ( p1 p2 p3 : point): point :=
(* TODO  What's wrong with the expression below ¯\_(ツ)_/¯ *)
((1%:R/2%:R)*(((p2.(x) + p3.(x))*(p2.(x) - p3.(x)) + (p2.(y) + p3.(y))*(p2.(y) - p3.(y)))*(p1.(y) - p2.(y)) - ((p1.(x) + p2.(x))*(p1.(x) - p2.(x)) + (p1.(y) + p2.(y))*(p1.(y) - p2.(y)))*(p2.(y) - p3.(y)))/((p1.(y) - p2.(y))*(p2.(x) - p3.(x)) - (p1.(x) - p2.(x))*(p2.(y) - p3.(y)))) 
((-1%:~R)/(2%:R)*(((p2.(x) + p3.(x))*(p2.(x) - p3.(x)) + (p2.(y) + p3.(y))*(p2.(y) - p3.(y)))*(p1.(x) - p2.(x)) - ((p1.(x) + p2.(x))*(p1.(x) - p2.(x)) + (p1.(y) + p2.(y))*(p1.(y) - p2.(y)))*(p2.(x) - p3.(x)))/((p1.(y) - p2.(y))*(p2.(x) - p3.(x)) - (p1.(x) - p2.(x))*(p2.(y) - p3.(y)))).
 *)
(*-------------------------- Geometric Functions --------------------------- *)

(* TODO Add a lemma states that this  (a + sqrtr disc) /b belongs to p1 and p2 curves*) 
Definition a (p1 p2 : point) ( y0 : R) : R :=
  p2.(x)*p1.(y) - p1.(x)*p2.(y) + (p1.(x) - p2.(x))*y0.

Definition b ( p1 p2 : point) ( y0 : R) : R := (p1.(y) - p2.(y)).

Definition disc ( p1 p2 : point) ( y0 : R) : R := 

 sqrtr ( (2%:R) *p1.(y)^2*p2.(y)^2 + p1.(y)*p2.(y)^3 + (p1.(x)^2 - (2%:R)*p1.(x)*p2.(x) + p2.(x)^2 + p1.(y)^2 - (2%:R)*p1.(y)*p2.(y) + p2.(y)^2)*y0^2 + (p1.(y)^3 + (p1.(x)^2 - (2%:R)*p1.(x)*p2.(x) + p2.(x)^2)*p1.(y))*p2.(y) - (p1.(y)^3 - p1.(y)*p2.(y)^2 + p2.(y)^3 + (p1.(x)^2 - (2%:R)*p1.(x)*p2.(x) + p2.(x)^2)*p1.(y) + (p1.(x)^2 - (2%:R)*p1.(x)*p2.(x) + p2.(x)^2 - p1.(y)^2)*p2.(y))*y0).
Check disc.

(* plus *) 
Definition par_inter_p (p1 p2 : point) (y0 : R) : R := 
  if p1.(y) == p1.(y) then  ((p1.(x)+p2.(x))/(2%:R)) 
  else ((a p1 p2 y0) + (disc p1 p2 y0))/(b p1 p2 y0) .
(* minus *)
Definition par_inter_m (p1 p2 : point) (y0 : R) : R := 
  if p1.(y) == p1.(y) then  ((p1.(x)+p2.(x))/(2%:R)) 
  else ((a p1 p2 y0) - (disc p1 p2 y0))/(b p1 p2 y0) .

Check par_inter_m.

Definition vertical_intersection (par site : point)  := 
               (* par indicates a parabola  *)
  ( (par.(x)-site.(x))^2+ par.(y)^2   - site.(y)^2)/( (2%:R)*(par.(y) - site.(y))).
Check andb.
Locate "&&".



(* Notation "p1 >= p2" := (geq p1 p2).
Notation "p1 < p2" := (less p1 p2).
Check  (1%:R >= 2%:R)%R.
 *)
Check true = false .
Check geq.
Check  [tuple true; false] .
Check  1%:R <= 2%:R.
Definition maxR (a1 a2 : R) : R := 
if a1 >= a2 then a1 else a2.
Definition minR (a1 a2 : R) : R := 
if a1 < a2 then a1 else a2.

Print Scopes.

Check leq.
(* This function picks the right or left intersection according to p1 p2 order *)
Definition pick_sol (p1 p2 : point) (y0:R) : R :=
  if geq p1 p2 then minR (par_inter_p p1 p2 y0) ( par_inter_m p1 p2 y0)
  else  maxR (par_inter_p p1 p2 y0) ( par_inter_m p1 p2 y0).
Check pick_sol.

Definition before (p1 p2 p : point) : bool*bool :=
  (* Pick the suitable intersection point *) 
  let sol  := pick_sol p1 p2 p.(y)  in
  if      sol  > p.(x) then (true, false)
  else if sol == p.(x) then (true, true)
  else (false, false).

(* This data structe says that  *)
Record arc_ind : Type := Arc_ind { ind1 : nat; ind2 : nat; both : bool}.
Check Arc_ind 1 2 true .
Definition add_ind ( i1 i2 : arc_ind) := 
Arc_ind (i1.(ind1) + i2.(ind1)) (i1.(ind2) + i2.(ind2))
        (orb i1.(both)  i2.(both)) .

Definition test := Arc ( Point 1%:R 2%:R ) false. 
Eval compute in add_ind (Arc_ind 1 2 true) (Arc_ind 1 2 false). 

(* TODO

Fixpoint search_veritcal (beachline  : seq arc) (q : point) : arc_ind := 
  let one  := Arc_ind 1 1 false in 
  let zero := Arc_ind 0 0 false in
  match beachline with 
  | [::] => zero |  h :: nil => zero
  | p1 :: p2 :: t =>  
      let b := before p1.(p) p2.(p) q in 
      if b.1 && b.2 
         then Arc_ind 1 2 true 
      else if b.1 then Arc_ind 1 1 false
      else add_ind one  (search_veritcal  ( p2 :: t)  q) (* TODO Something wrong *)
   end. (*  Cannot guess decreasing argument of fix.
            Solution 1: use measure one beachline size
            Solution 2: Read CPDT!*)
 *)

(* Definition line_intersection(l1 l2 : point ) : point :=.
(* TODO: Defines equality for points  *)
 *)
Definition collinear ( p1 p2 p3 : point ): bool := false .  
(*   if p1 == p2 || p2 == p3 || p3 == p1                     then true
  else if p1.(y) == p2.(y) == p3.(y) == 0%:R              then true
  else if p1.(x)/p1.(y) == p2.(x)/p2.(y) == p3.(x)/p3.(y) then true
  else false.
 *)  
Definition nulArc := Arc (Point 1%:R 2%:R) false.

(*------------------------- Circle event helpers ------------------------ *)

Definition check_circle_event ( ind : nat) ( y0 : R) (beachline : seq arc) 
                              ( Q : PQueue) : (seq arc * PQueue) := 
  let l := (nth nulArc beachline (ind -1)).(p) in
  let m := (nth nulArc beachline (ind)).(p)    in
  let r := (nth nulArc beachline (ind +1)).(p) in
   
(* TODO    The term "0" has type "nat" while it is expected to have type
 "bool".
 coq is flawless ಠ_ಠ *) 
  if (ind == 0%nat || ind == (size beachline)-1 ) then 
           (beachline, Q)
  
  else if (collinear l m r) || 
  (((m.(y) - l.(y))*(r.(x) - l.(x)) - (r.(y) - l.(y))*(m.(x) - l.(x))) > 0%:R)
       then (beachline, Q)
  else
    let p = m.(p_l)                                         in
    let c = circumcenter l m r                              in
    let r = sqrtr ((c.(x) - p.(x))^2   + (c.(y) - p.(y))^2) in (* radius *)
    let upper = r + c.(y)                                   in
    if  upper < y0 then (beachline, Q)
    else 
      let update   := Arc m true                            in
      let newBeach := set_nth nulArc beachline ind update   in
      let newEvent := Event l m r m.(y)                     in 
      let newQ     := prique (Q.(push) newEvent)            in
          (newBeach, newQ).

    

  

Definition false_alarm (ind : nat) ( beachline : seq arc) ( Q : PQueue) :
                       ( seq arc , PQueue) := 
  current = nth nulArc s ind 
  cond    = current.(circle)
  if ~~ cond then  
    (beachline, Q)
  else 
    let update   := Arc current.(p) true                  in
    let newBeach := set_nth nulArc beachline ind update   in
    let l_m_r := (nth nulArc beachline ind -1) (nth nulArc beachline ind )
                 (nth nulArc beachline ind +1) (* TODO incomp *) in
    let newQ     := rem l_m_r Q                           in
     (newBeach, newQ).


(*----------------------------   Main functions  -------------------------- *)
Definition voronoi_diagram (sites : seq point) : seq edge := .

Definition special_case  :  :=.
Definition handle_site_event ( e : event)  (beachline : seq arc)(edges : seq edge) 
                             ( Q : PQueue )   :  :=
                             .


Definition handle_site_event ( e : event)  (beachline : seq arc)(edges : seq edge) 
                             ( Q : PQueue )   : track :=
                             if .