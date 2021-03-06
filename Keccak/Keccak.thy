(* Generated by Lem from eth-isabelle/lem/keccak.lem *)

theory "Keccak" 

imports
  Main
  (* HOL-Library.Word *)
  "HOL-Library.Word"
  "../Word_Lib/Traditional_Infix_Syntax"
  "../Word_Lib/Rsplit"
  "../Word_Lib/Reversed_Bit_Lists"

begin 



(* Copyright 2016 Sami MÃ¤kelÃ¤
 Licensed under the Apache License; Version 2.0 (the "License"); 
 you may not use this file except in compliance with the License. 
 You may obtain a copy of the License at 
   http://www.apache.org/licenses/LICENSE-2.0 
Unless required by applicable law or agreed to in writing; software 
 distributed under the License is distributed on an "AS IS" BASIS; 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND; either express or implied.
See the License for the specific language governing permissions and
limitations under the License. 
*)

(* Revised by Mario Alvarez to remove Lem dependencies *)


definition "rotl64 (x :: 64 word) n = (word_rotl n x :: 64 word)"

(*
definition rotl64  :: " 64 word \<Rightarrow> nat \<Rightarrow> 64 word "  where 
     " rotl64 w n = ( (w >> (( 64 :: nat) - n)) OR (w << n))"
*)

definition big  :: " 64 word "  where 
     "big = (((word_of_int 1) ::  64 word) <<( 63 :: nat))"

definition two31  :: " 64 word "  where 
     "two31 = (((word_of_int 1) ::  64 word) <<( 31 :: nat))"

definition two15  :: " 64 word "  where 
     "two15 = (((word_of_int 1) ::  64 word) <<( 15 :: nat))"

definition keccakf_randc  :: "( 64 word)list "  where 
     " keccakf_randc = ( [((word_of_int 1) ::  64 word),(((word_of_int 130) ::  64 word) OR two15),((((word_of_int 138) ::  64 word) OR big) OR two15),(((((word_of_int 0) ::  64 word) OR big) OR two31) OR two15),(((word_of_int 139) ::  64 word) OR two15),(((word_of_int 1) ::  64 word) OR two31),(((((word_of_int 129) ::  64 word) OR big) OR two31) OR two15),((((word_of_int 9) ::  64 word) OR big) OR two15),((word_of_int 138) ::  64 word),((word_of_int 136) ::  64 word),((((word_of_int 9) ::  64 word) OR two31) OR two15),(((word_of_int 10) ::  64 word)  OR two31),((((word_of_int 139) ::  64 word) OR two31) OR two15),(((word_of_int 139) ::  64 word) OR big),((((word_of_int 137) ::  64 word) OR big) OR two15),((((word_of_int 3) ::  64 word) OR big) OR two15),((((word_of_int 2) ::  64 word) OR big) OR two15),(((word_of_int 128) ::  64 word) OR big),(((word_of_int 10) ::  64 word) OR two15),((((word_of_int 10) ::  64 word) OR big) OR two31),(((((word_of_int 129) ::  64 word) OR big) OR two31) OR two15),((((word_of_int 128) ::  64 word) OR big) OR two15),(((word_of_int 1) ::  64 word) OR two31),(((((word_of_int 8) ::  64 word) OR big) OR two31) OR two15)
])"


definition keccakf_rotc  :: "(nat)list "  where 
     " keccakf_rotc = ( [( 1 :: nat),( 3 :: nat),( 6 :: nat),( 10 :: nat),( 15 :: nat),( 21 :: nat),( 28 :: nat),( 36 :: nat),( 45 :: nat),( 55 :: nat),( 2 :: nat),( 14 :: nat),( 27 :: nat),( 41 :: nat),( 56 :: nat),( 8 :: nat),( 25 :: nat),( 43 :: nat),( 62 :: nat),( 18 :: nat),( 39 :: nat),( 61 :: nat),( 20 :: nat),( 44 :: nat)
])"

definition keccakf_piln  :: "(nat)list "  where 
     " keccakf_piln = ( [( 10 :: nat),( 7 :: nat),( 11 :: nat),( 17 :: nat),( 18 :: nat),( 3 :: nat),( 5 :: nat),( 16 :: nat),( 8 :: nat),( 21 :: nat),( 24 :: nat),( 4 :: nat),( 15 :: nat),( 23 :: nat),( 19 :: nat),( 13 :: nat),( 12 :: nat),( 2 :: nat),( 20 :: nat),( 14 :: nat),( 22 :: nat),( 9 :: nat),( 6 :: nat),( 1 :: nat)
])"

(* originally in lem pervasives *)
fun index :: "'a list \<Rightarrow> nat \<Rightarrow> 'a option" where
"index [] _ = None"
| "index (h#t) 0 = Some h"
| "index (h#t) (Suc n') = index t n'"

definition get  :: "( 64 word)list \<Rightarrow> nat \<Rightarrow> 64 word "  where 
     " get lst n = ( (case index lst n of
   Some x => x
 | None =>((word_of_int 0) ::  64 word)
))"


definition get_n  :: "(nat)list \<Rightarrow> nat \<Rightarrow> nat "  where 
     " get_n lst n = ( (case  index lst n of
   Some x => x
 | None =>( 0 :: nat)
))"

(* originally in lem pervasives
   generate a list by applying f to values from 0 to (n-1)
   we may not even need this for setf
 *)
fun genlist :: "(nat \<Rightarrow> 'a) \<Rightarrow> nat \<Rightarrow>  'a list" where
"genlist f 0 = []"
| "genlist f (Suc n') =
   genlist f n' @ [f n']"

definition setf  :: "( 64 word)list \<Rightarrow> nat \<Rightarrow> 64 word \<Rightarrow>( 64 word)list "  where 
     " setf lst n w = (
  if List.length lst < n then (lst @ genlist ( \<lambda>x . (case x of _ =>((word_of_int 0) :: 64 word) ))
                                             ((List.length lst - n) -( 1 :: nat))) @ [w]
  else (List.take n lst @ [w]) @ List.drop (n+( 1 :: nat)) lst )"

definition theta1  :: " nat \<Rightarrow>( 64 word)list \<Rightarrow> 64 word "  where 
     " theta1 i st = (
  ((((get st i) XOR
  (get st (i +( 5 :: nat)))) XOR
  (get st (i +( 10 :: nat)))) XOR
  (get st (i +( 15 :: nat)))) XOR
  (get st (i +( 20 :: nat))))"

definition theta_t  :: " nat \<Rightarrow>( 64 word)list \<Rightarrow> 64 word "  where 
     " theta_t i bc = (
  (get bc ((i +( 4 :: nat)) mod( 5 :: nat))) XOR (rotl64 (get bc ((i +( 1 :: nat)) mod( 5 :: nat)))(( 1 :: nat))))"

definition theta  :: "( 64 word)list \<Rightarrow>( 64 word)list "  where 
     " theta st = (
  (let bc = (genlist (\<lambda> i .  theta1 i st)(( 5 :: nat))) in
  (let t = (genlist (\<lambda> i .  theta_t i bc)(( 5 :: nat))) in
  genlist (\<lambda> ji .  (get st ji) XOR (get t (ji mod( 5 :: nat))))(( 25 :: nat)))))"

definition rho_pi_inner  :: " 64 word*( 64 word)list \<Rightarrow> nat \<Rightarrow> 64 word*( 64 word)list "  where 
     " rho_pi_inner t_st i = (
  (let j = (get_n keccakf_piln i) in
  (let bc = (get (snd t_st) j) in
  (bc, setf (snd t_st) j (rotl64 (fst t_st) (get_n keccakf_rotc i))))))"


definition rho_pi_changes  :: " nat \<Rightarrow> 64 word*( 64 word)list \<Rightarrow> 64 word*( 64 word)list "  where 
     " rho_pi_changes i t_st = ( List.foldl rho_pi_inner t_st (genlist (\<lambda> x .  x) i))"

definition rho_pi  :: "( 64 word)list \<Rightarrow>( 64 word)list "  where 
     " rho_pi st = ( snd (rho_pi_changes(( 24 :: nat)) (get st(( 1 :: nat)), st)))"

definition chi_for_j  :: "( 64 word)list \<Rightarrow>( 64 word)list "  where 
     " chi_for_j st_slice = (
  genlist (\<lambda> i .  (get st_slice i) XOR (((NOT (get st_slice ((i +( 1 :: nat)) mod( 5 :: nat))))) AND (get st_slice ((i +( 2 :: nat)) mod( 5 :: nat)))))(( 5 :: nat)))"

definition filterI  :: " 'a list \<Rightarrow>(nat \<Rightarrow> bool)\<Rightarrow> 'a list "  where 
     " filterI lst pred = (
  List.map fst (List.filter (\<lambda> p .  pred (snd p)) (List.zip lst (genlist (\<lambda> i .  i) (List.length lst)))))"

definition chi  :: "( 64 word)list \<Rightarrow>( 64 word)list "  where 
     " chi st = (
  List.concat (genlist (\<lambda> j .  chi_for_j (filterI st (\<lambda> i .  ((j *( 5 :: nat)) \<le> i) \<and> (i \<le> ((j*( 5 :: nat)) +( 5 :: nat))))))(( 5 :: nat))))"

definition iota  :: " nat \<Rightarrow>( 64 word)list \<Rightarrow>( 64 word)list "  where 
     " iota r st = ( setf st(( 0 :: nat)) (get st(( 0 :: nat)) XOR get keccakf_randc r))"

definition for_inner  :: "( 64 word)list \<Rightarrow> nat \<Rightarrow>( 64 word)list "  where 
     " for_inner st r = ( iota r (chi (rho_pi (theta st))))"


definition keccakf_rounds  :: " nat "  where 
     " keccakf_rounds = (( 24 :: nat))"


type_synonym byte ="  8 word "

fun  word_rsplit_aux  :: "(bool)list \<Rightarrow> nat \<Rightarrow>( 8 word)list "  where 
     " word_rsplit_aux lst 0 = ( [])"
|" word_rsplit_aux lst ((Suc n)) = ( of_bl (List.take(( 8 :: nat)) lst) # word_rsplit_aux (List.drop(( 8 :: nat)) lst) n )"


definition word_rcat_k  :: "( 8 word)list \<Rightarrow> 64 word "  where 
     " word_rcat_k lst = ( of_bl (List.concat (List.map to_bl lst)))"


definition invert_endian  :: " 64 word \<Rightarrow> 64 word "  where 
     " invert_endian w = ( word_rcat_k (List.rev (word_rsplit w)))"


definition keccakf  :: "( 64 word)list \<Rightarrow>( 64 word)list "  where 
     " keccakf st = ( List.foldl for_inner st (genlist (\<lambda> i .  i) keccakf_rounds))"


definition mdlen  :: " nat "  where 
     " mdlen = (( 256 :: nat) div( 8 :: nat))"

definition rsiz  :: " nat "  where 
     " rsiz = (( 200 :: nat) - (mdlen *( 2 :: nat)))"


definition word8_to_word64  :: " 8 word \<Rightarrow> 64 word "  where 
     " word8_to_word64 w = (word_of_int (uint w))"


definition update_byte  :: " 8 word \<Rightarrow> nat \<Rightarrow>( 64 word)list \<Rightarrow>( 64 word)list "  where 
     " update_byte i p st = ( setf st (p div( 8 :: nat)) ((get st (p div( 8 :: nat))) XOR ((word8_to_word64 i) << (( 8 :: nat) * (p mod( 8 :: nat))))))"

(*
function (sequential,domintros)  sha3_update  :: "( 8 word)list \<Rightarrow> nat \<Rightarrow>( 64 word)list \<Rightarrow> nat*( 64 word)list "  where 
     " sha3_update ([]) pos st = ( (pos, st))"
|" sha3_update (c # rest) pos st = (
    if (pos \<le> rsiz) then sha3_update rest (pos +( 1 :: nat)) (update_byte c pos st)
   else sha3_update rest(( 0 :: nat)) (keccakf (update_byte c pos st)))" 
by pat_completeness auto
*)

fun sha3_update  :: "( 8 word)list \<Rightarrow> nat \<Rightarrow>( 64 word)list \<Rightarrow> nat*( 64 word)list "  where 
     " sha3_update ([]) pos st = ( (pos, st))"
|" sha3_update (c # rest) pos st = (
    if (pos \<le> rsiz) then sha3_update rest (pos +( 1 :: nat)) (update_byte c pos st)
   else sha3_update rest(( 0 :: nat)) (keccakf (update_byte c pos st)))" 


definition keccak_final  :: " nat \<Rightarrow>( 64 word)list \<Rightarrow>( 8 word)list "  where 
     " keccak_final p st = (
   (let st0 = (update_byte(((word_of_int 1) ::  8 word)) p st) in
   (let st1 = (update_byte(((word_of_int 128) ::  8 word)) (rsiz -( 1 :: nat)) st0) in
   (let st2 = (List.take(( 4 :: nat)) (keccakf st1)) in
   List.concat (List.map (\<lambda> x .  List.rev (word_rsplit x)) st2)))))"


definition initial_st  :: "( 64 word)list "  where 
     " initial_st = ( genlist ( \<lambda>x .  
  (case  x of _ =>((word_of_int 0) :: 64 word) ))(( 25 :: nat)))"


definition initial_pos  :: " nat "  where 
     " initial_pos = (( 0 :: nat))"


definition keccak'  :: "(byte)list \<Rightarrow>(byte)list "  where 
     " keccak' input = (
   (let mid = (sha3_update input initial_pos initial_st) in
   keccak_final (fst mid) (snd mid)))"


type_synonym w256 ="  256 word "

definition list_fill_right  :: " bool \<Rightarrow> nat \<Rightarrow>(bool)list \<Rightarrow>(bool)list "  where 
     " list_fill_right filled target orig = (
  if List.length orig \<ge> target then orig else
  (let filling_len = (target - List.length orig) in
  (@) orig (List.replicate filling_len filled)))"


definition list_fill_left  :: " bool \<Rightarrow> nat \<Rightarrow>(bool)list \<Rightarrow>(bool)list "  where 
     " list_fill_left filled target orig = (
  if List.length orig \<ge> target then orig else
  (let filling_len = (target - List.length orig) in
  (@) (List.replicate filling_len filled) orig))"


definition keccak  :: "(byte)list \<Rightarrow> 256 word "  where 
     " keccak input = ( Word.word_rcat (keccak' input))"



end
