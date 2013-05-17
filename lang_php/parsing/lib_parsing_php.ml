(*s: lib_parsing_php.ml *)
(*s: Facebook copyright *)
(* Yoann Padioleau
 * 
 * Copyright (C) 2009-2011 Facebook
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation, with the
 * special exception on linking described in file license.txt.
 * 
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
 * license.txt for more details.
 *)
(*e: Facebook copyright *)
open Common

(*s: basic pfff module open and aliases *)
open Ast_php 

module Ast = Ast_php
module Flag = Flag_parsing_php
(*e: basic pfff module open and aliases *)
module V = Visitor_php 
module V2 = Map_php 

(*****************************************************************************)
(* Wrappers *)
(*****************************************************************************)
let pr2, pr2_once = Common2.mk_pr2_wrappers Flag.verbose_parsing

(*****************************************************************************)
(* Filenames *)
(*****************************************************************************)

let is_php_script file = 
  Common.with_open_infile file (fun chan ->
    try 
      let l = input_line chan in
      l =~ "#!/usr/.*/php" ||
      l =~ "#!/bin/env php" ||
      l =~ "#!/usr/bin/env php"

    with End_of_file -> false
  )
let is_php_filename filename =
  (filename =~ ".*\\.php$") || (filename =~ ".*\\.phpt$") ||
  (* hotcrp uses this extension *)
  (filename =~ ".*\\.inc") ||
  (* hack uses this extension *)
(* TODO  (filename =~ ".*\\.hhi") *)
  false

let is_php_file filename =
  is_php_filename filename || is_php_script filename

(* 
 * In command line tools like git or mercurial, many operations works 
 * when a file, a set of files, or even dirs are passed as parameters.
 * We want the same with pfff, hence this small helper function that
 * transform such files_or_dirs into a flag set of filenames.
 *)
let find_php_files_of_dir_or_files ?(verbose=false) xs = 
  Common.files_of_dir_or_files_no_vcs_nofilter xs 
  +> List.filter (fun filename ->
    let valid = is_php_file filename in
    if not valid && verbose
    then pr2 ("not analyzing: " ^ filename);
    valid
  ) +> Common.sort

(*****************************************************************************)
(* Extract infos *)
(*****************************************************************************)
(*s: extract infos *)
let extract_info_visitor recursor = 
  let globals = ref [] in
  let hooks = { V.default_visitor with
    V.kinfo = (fun (k, _) i -> 
      (* most of the time when you use ii_of_any, you want to use
       * functions like max_min_pos which works only on origin tokens
       * hence the filtering done here.
       * 
       * ugly: For PHP we use a fakeInfo only for generating a fake left
       * brace for abstract methods.
       *)
      match i.Parse_info.token with
      | Parse_info.OriginTok _ ->
        Common.push2 i globals
      | _ ->
        ()
    )
  } in
  begin
    let vout = V.mk_visitor hooks in
    recursor vout;
    List.rev !globals
  end
(*x: extract infos *)
let ii_of_any any = 
  extract_info_visitor (fun visitor -> visitor any)
(*e: extract infos *)

(*****************************************************************************)
(* Abstract position *)
(*****************************************************************************)
(*s: abstract infos *)
let abstract_position_visitor recursor = 
  let hooks = { V2.default_visitor with
    V2.kinfo = (fun (k, _) i -> 
      { i with Parse_info.token = Parse_info.Ab }
    )
  } in
  begin
    let vout = V2.mk_visitor hooks in
    recursor vout;
  end
(*x: abstract infos *)
let abstract_position_info_any x = 
  abstract_position_visitor (fun visitor -> visitor.V2.vany x)
(*e: abstract infos *)

(*****************************************************************************)
(* Max min, range *)
(*****************************************************************************)
(*s: max min range *)
(*x: max min range *)
let info_to_fixpos ii =
  match Ast_php.pinfo_of_info ii with
  | Parse_info.OriginTok pi -> 
      (* Ast_cocci.Real *)
      pi.Parse_info.charpos
  | Parse_info.FakeTokStr _
  | Parse_info.Ab 
  | Parse_info.ExpandedTok _
    -> failwith "unexpected abstract or faketok"
  
let min_max_by_pos xs = 
  let (i1, i2) = Parse_info.min_max_ii_by_pos xs in
  (info_to_fixpos i1, info_to_fixpos i2)

let (range_of_origin_ii: Ast_php.tok list -> (int * int) option) = 
 fun ii -> 
  let ii = List.filter Ast_php.is_origintok ii in
  try 
    let (min, max) = Parse_info.min_max_ii_by_pos ii in
    assert(Ast_php.is_origintok max);
    assert(Ast_php.is_origintok min);
    let strmax = Ast_php.str_of_info max in
    Some 
      (Ast_php.pos_of_info min, Ast_php.pos_of_info max + String.length strmax)
  with _ -> 
    None
(*e: max min range *)

(*****************************************************************************)
(* Print helpers *)
(*****************************************************************************)

(* obsolete: now catch Parse_php.Parse_error *)
let print_warning_if_not_correctly_parsed ast file =
  if ast +> List.exists (function 
  | Ast_php.NotParsedCorrectly _ -> true
  | _ -> false)
  then begin
    Common.pr2 (spf "warning: parsing problem in %s" file);
    Common.pr2_once ("Use -parse_php to diagnose");
    (* old: 
     * Common.pr2_once ("Probably because of XHP; -xhp may be helpful"); 
     *)
  end

(*****************************************************************************)
(* Ast getters *)
(*****************************************************************************)
(*s: ast getters *)
let get_funcalls_any any = 
  let h = Hashtbl.create 101 in
  
  let hooks = { V.default_visitor with
    (* TODO if nested function ??? still wants to report ? *)
    V.klvalue = (fun (k,vx) x ->
      match x with
      | FunCallSimple (callname, args) ->
          let str = Ast_php.name callname in
          Hashtbl.replace h str true;
          k x
      | _ -> k x
    );
  } 
  in
  let visitor = V.mk_visitor hooks in
  visitor any;
  Common.hashset_to_list h
(*x: ast getters *)
(*x: ast getters *)
let get_constant_strings_any any = 
  let h = Hashtbl.create 101 in

  let hooks = { V.default_visitor with
    V.kconstant = (fun (k,vx) x ->
      match x with
      | String (str,ii) ->
          Hashtbl.replace h str true;
      | _ -> k x
    );
    V.kencaps = (fun (k,vx) x ->
      match x with
      | EncapsString (str, ii) ->
          Hashtbl.replace h str true;
      | _ -> k x
    );
  }
  in
  (V.mk_visitor hooks) any;
  Common.hashset_to_list h
(*x: ast getters *)

let get_funcvars_any any =
  let h = Hashtbl.create 101 in
  
  let hooks = { V.default_visitor with

    V.klvalue = (fun (k,vx) x ->
      match x with
      | FunCallVar (qu_opt, var, args) ->
          (* TODO enough ? what about qopt ? 
           * and what if not directly a Var ?
           * 
           * and what about call_user_func ? should be
           * transformed at parsing time into a FunCallVar ?
           *)
          (match var with
          | Var (dname, _scope) ->
              let str = Ast_php.dname dname in
              Hashtbl.replace h str true;
              k x

          | _ -> k x
          )
      | _ ->  k x
    );
  } 
  in
  let visitor = V.mk_visitor hooks in
  visitor any;
  Common.hashset_to_list h
(*e: ast getters *)

let get_static_vars_any any =
  any +> V.do_visit_with_ref (fun aref -> { V.default_visitor with
    V.kstmt = (fun (k,vx) x ->
      match x with
      | StaticVars (tok, xs, tok2) ->
          xs +> Ast.uncomma +> List.iter (fun (dname, affect_opt) -> 
            Common.push2 dname aref
          );
      | _ -> 
          k x
    );
  })
  
(* todo? do last_stmt_is_a_return isomorphism ? *)
let get_returns_any any = 
  V.do_visit_with_ref (fun aref -> { V.default_visitor with
    V.kstmt = (fun (k,vx) x ->
      match x with
      | Return (tok1, Some e, tok2) ->
          Common.push2 e aref
      | _ -> k x
    )}) any

let get_vars_any any = 
  V.do_visit_with_ref (fun aref -> { V.default_visitor with
    V.klvalue = (fun (k,vx) x ->
      match x with
      | Var (dname, _scope) ->
          Common.push2 dname aref
      | _ -> k x
    );
    V.kexpr = (fun (k, vx) x ->
      match x with
      (* todo? sure ?? *)
      | Lambda (l_use, def) ->
          l_use +> Common.do_option (fun (_tok, xs) ->
            xs +> Ast.unparen +> Ast.uncomma +> List.iter (function
            | LexicalVar (is_ref, dname) ->
                Common.push2 dname aref
            )
          );
          k x
      | _ -> k x
    );
  }) any

(*****************************************************************************)
(* Ast adapters *)
(*****************************************************************************)

(* todo? let lvalue_to_expr ?? *)

let top_statements_of_program ast = 
  ast +> List.map (function
  | StmtList xs -> xs
  | FinalDef _|NotParsedCorrectly _
  | ClassDef _| FuncDef _ | ConstantDef _ | NamespaceDef _ 
      -> []
  ) +> List.flatten  

let toplevel_to_entity x = 
  match x with
  | StmtList v1 -> StmtListE v1
  | FuncDef v1  -> FunctionE v1
  | ClassDef v1 -> ClassE v1
  | ConstantDef v1 -> ConstantE v1
  (* todo? *)
  | NotParsedCorrectly xs ->
      MiscE xs
  | NamespaceDef v1 -> NamespaceE v1
  | FinalDef v1 ->
      MiscE [v1]

(* We often do some analysis on "unit" of code like a function,
 * a method, or toplevel statements. One can not use the
 * 'toplevel' type for that because it contains Class and Interface which
 * are too coarse grained; the method granularity is better.
 * 
 * For instance it makes sense to have a CFG for a function, a method,
 * or toplevel statements but a CFG for a class does not make sense.
 *)
let functions_methods_or_topstms_of_program prog =
  let funcs = ref [] in
  let methods = ref [] in
  let toplevels = ref [] in

  let visitor = V.mk_visitor { V.default_visitor with
    V.kfunc_def = (fun (k, _) def -> 
      match def.f_type with
      | FunctionRegular -> Common.push2 def funcs
      | MethodRegular | MethodAbstract -> Common.push2 def methods
      | FunctionLambda -> ()
    );
    V.ktop = (fun (k, _) top ->
      match top with
      | StmtList xs ->
          Common.push2 xs toplevels
      | _ ->
          k top
    );
  }
  in
  visitor (Program prog);
  !funcs, !methods, !toplevels


(* do some isomorphisms for declaration vs assignement *)
let get_vars_assignements_any recursor = 
  (* We want to group later assignement by variables, and 
   * so we want to use function like Common.group_by_xxx 
   * which requires to have identical key. Each dname occurence 
   * below has a different location and so we can use dname as 
   * key, but the name of the variable can be used, hence the use
   * of Ast.dname
   *)
  V.do_visit_with_ref (fun aref -> { V.default_visitor with
      V.kstmt = (fun (k,vx) x ->
        match x with
        | StaticVars (tok, xs, tok2) ->
            xs +> Ast.uncomma +> List.iter (fun (dname, affect_opt) -> 
              let s = Ast.dname dname in
              affect_opt +> Common.do_option (fun (_tok, scalar) ->
                Common.push2 (s, scalar) aref;
              );
            );
        | _ -> 
            k x
      );

      V.kexpr = (fun (k,vx) x ->
        match x with
        | Assign (lval, _, e) 
        | AssignOp (lval, _, e) ->
            (* the expression itself can contain assignements *)
            k x; 
            
            (* for now we handle only simple direct assignement to simple
             * variables *)
            (match lval with
            | Var (dname, _scope) ->
                let s = Ast.dname dname in
                Common.push2 (s, e) aref;
            | _ ->
                ()
            )
        (* todo? AssignRef AssignNew ? *)
        | _ -> 
            k x
      );
    }
  ) recursor +> Common.group_assoc_bykey_eff

(*e: lib_parsing_php.ml *)
