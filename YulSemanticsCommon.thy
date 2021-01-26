theory YulSemanticsCommon imports YulSyntax
begin

(* Primitives common to both small and big step Yul semantics *)
datatype mode =
  Regular
  | Break
  | Continue
  | Leave

(* allow direct access to locals? *)
datatype ('g, 'v, 't) YulFunctionBody =
  YulBuiltin "'g \<Rightarrow> 'v list \<Rightarrow> (('g * 'v list) + String.literal)"
  | YulFunction "('v, 't) YulStatement list"

datatype ('g, 'v, 't) function_sig =
  YulFunctionSig
  (YulFunctionSigArguments: "'t YulTypedName list")
  (YulFunctionSigReturnValues: "'t YulTypedName list")
  (YulFunctionSigBody: "('g, 'v, 't) YulFunctionBody")

(*
type_synonym 'v locals = "YulIdentifier \<Rightarrow> 'v option"
*)

type_synonym 'v locals = "(YulIdentifier * 'v) list"

(* TODO: changes here
   - locals should no longer be a list. just single locals + list of visible vars (?)
   - maybe funs also doesn't need to be a list. can just be a local also.
 *)

type_synonym vset = "unit locals"

(* for nested function calls, we need a stack of
   - result value lists
   - locals
do we also need a set of fun. defs.?
*)
type_synonym 'v frame =
  "('v list * 'v locals)"

definition locals_empty :: "'v locals" where
"locals_empty = []"

(* restrict e1 to the identifiers of e2 
   note that v2 need not be the same type - we can use this to store
   variable-name sets as unit locals
*)
fun restrict :: "'v1 locals \<Rightarrow> 'v2 locals \<Rightarrow> 'v1 locals" where
"restrict [] e2 = []"
| "restrict ((k1, v1)#e1t) (e2) =
  (case map_of e2 k1 of
    None \<Rightarrow> restrict e1t e2
    | Some _ \<Rightarrow> (k1, v1) # restrict e1t e2)"

fun strip_id_type :: "'t YulTypedName \<Rightarrow> YulIdentifier" where
"strip_id_type (YulTypedName name type) = name"

fun strip_id_types :: "'t YulTypedName list \<Rightarrow> YulIdentifier list" where
"strip_id_types l =
  List.map strip_id_type l"

fun del_value :: "'v locals \<Rightarrow> YulIdentifier \<Rightarrow> 'v locals" where
"del_value [] _ = []"
| "del_value ((k, v)#e1t) k' =
   (if k = k' then del_value e1t k'
    else (k, v)#del_value e1t k')"

(* update (or insert if not present) a value into locals *)
fun put_value :: "'v locals \<Rightarrow> YulIdentifier \<Rightarrow> 'v \<Rightarrow> 'v locals" where
"put_value L k v =
  (k, v) # (del_value L k)"

fun put_values :: "'v locals \<Rightarrow> YulIdentifier list \<Rightarrow> 'v list \<Rightarrow> 'v locals option" where
"put_values L [] [] = Some L"
| "put_values L (ih#it) (vh#vt) =
   (case put_values L it vt of
    None \<Rightarrow> None
    | Some L' \<Rightarrow> Some (put_value L' ih vh))"
| "put_values L _ _ = None"

fun get_values :: "'v locals \<Rightarrow> YulIdentifier list \<Rightarrow> 'v list option" where
"get_values L ids =
   List.those (List.map (map_of L) (ids))"

fun make_locals :: "(YulIdentifier * 'v) list \<Rightarrow> 'v locals" where
"make_locals [] = locals_empty"
| "make_locals ((ih, vh)#t) =
    put_value (make_locals t) ih vh"

fun strip_locals :: "'v locals \<Rightarrow> unit locals" where
"strip_locals [] = []"
| "strip_locals ((k, _)#t) =
   (k, ())#strip_locals t"

syntax plus_literal_inst.plus_literal :: "String.literal \<Rightarrow> String.literal \<Rightarrow> String.literal"
  ("_ @@ _")

(* store results of yul statements *)
record ('g, 'v, 't) result =
  global :: "'g"
  locals :: "'v locals"
  (* value stack, used within expression evaluation, as well as
     for assignments and function arguments *)
  vals :: "'v list"  
  frames :: "'v frame list"
  (* which functions are currently visible *)
  funs :: "('g, 'v, 't) function_sig locals"
  (* TODO: this was a mode option *)
  (*mode :: "mode"*)

datatype ('g, 'v, 't, 'z) YulResult =
  YulResult "('g, 'v, 't, 'z) result_scheme"
  (* errors can optionally carry failed state *)
  | ErrorResult "String.literal" "('g, 'v, 't, 'z) result_scheme option"


(* "locale parameters" passed to Yul semantics
   (capture behaviors needed by certain control primitives) *)
record ('g, 'v, 't) YulDialect =
  is_truthy :: "'v \<Rightarrow> bool"
  init_state :: "'g"
  default_val :: "'v"
  builtins :: "('g, 'v, 't) function_sig locals"

end