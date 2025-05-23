/*========================================================================*/
/*                                                                        */
/*  Copyright (c) 2015-2017 Shaked Flur                                   */
/*  Copyright (c) 2015-2017 Kathyrn Gray                                  */
/*  Copyright (c) 2025 Brian Campbell                                     */
/*  Copyright (c) 2025 Thibaut Pérami                                     */
/*  All rights reserved.                                                  */
/*                                                                        */
/*  This software was developed by the University of Cambridge Computer   */
/*  Laboratory as part of the Rigorous Engineering of Mainstream Systems  */
/*  (REMS) project, funded by EPSRC grant EP/K008528/1.                   */
/*                                                                        */
/*  Redistribution and use in source and binary forms, with or without    */
/*  modification, are permitted provided that the following conditions    */
/*  are met:                                                              */
/*  1. Redistributions of source code must retain the above copyright     */
/*     notice, this list of conditions and the following disclaimer.      */
/*  2. Redistributions in binary form must reproduce the above copyright  */
/*     notice, this list of conditions and the following disclaimer in    */
/*     the documentation and/or other materials provided with the         */
/*     distribution.                                                      */
/*                                                                        */
/*  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''    */
/*  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED     */
/*  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A       */
/*  PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR   */
/*  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,          */
/*  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT      */
/*  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF      */
/*  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND   */
/*  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,    */
/*  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT    */
/*  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF    */
/*  SUCH DAMAGE.                                                          */
/*                                                                        */
/*========================================================================*/

default Order dec

let b1 = bitone
let b0 = bitzero

val "reg_deref" : forall ('a : Type). register('a) -> 'a effect {rreg}
/* sneaky deref with no effect necessary for bitfield writes */
val _reg_deref = "reg_deref" : forall ('a : Type). register('a) -> 'a

/* this is here because if we don't have it before including vector_dec 
   we get infinite loops caused by interaction with bool/bit casts */
/* val eq_bit2 = "eq_bit" : (bit, bit) -> bool */
/* overload operator == = {eq_bit2} */

$include <smt.sail>
$include <flow.sail>
$include <arith.sail>
$include <option.sail>
$include <vector_dec.sail>
$include <reverse_endianness.sail>

$include <regfp.sail>

infix 7 >>
infix 7 <<
infix 7 ^^

val shift_bits_left = "shift_bits_left" : forall 'n 'm. (bits('n), bits('m)) -> bits('n)
val shift_bits_right = "shift_bits_right" : forall 'n 'm. (bits('n), bits('m)) -> bits('n)
val shift_left = "shiftl" : forall 'm. (bits('m), int) -> bits('m)
val shift_right = "shiftr" : forall 'm. (bits('m), int) -> bits('m)

overload operator << = {shift_bits_left, shift_left}
overload operator >> = {shift_bits_right, shift_right}


val operator ^^ = "replicate_bits" : forall 'n 'm. (bits('n), int('m)) -> bits('n * 'm)



infix 4 <_s
infix 4 >=_s
infix 4 <_u
infix 4 >=_u
infix 4 <=_u

val operator <_s  : forall 'n, 'n > 0. (bits('n), bits('n)) -> bool
val operator >=_s : forall 'n, 'n > 0. (bits('n), bits('n)) -> bool
val operator <_u  : forall 'n. (bits('n), bits('n)) -> bool
val operator >=_u : forall 'n. (bits('n), bits('n)) -> bool
val operator <=_u : forall 'n. (bits('n), bits('n)) -> bool

function operator <_s  (x, y) = signed(x) < signed(y)
function operator >=_s (x, y) = signed(x) >= signed(y)
function operator <_u  (x, y) = unsigned(x) < unsigned(y)
function operator >=_u (x, y) = unsigned(x) >= unsigned(y)
function operator <=_u (x, y) = unsigned(x) <= unsigned(y)

val pow2_atom = "pow2" : forall 'n. int('n) -> int(2 ^ 'n)
val pow2_int = "pow2" : int -> int

val cast_bool_bit : bool -> bit
function cast_bool_bit(b) = 
  match b {
    true => b1,
    false => b0
  }

val cast_bit_bool : bit -> bool
function cast_bit_bool (b) = 
  match b {
    bitzero => false,
    bitone => true
  }




val and_bits = {c:"and_bits", _: "and_vec"} : forall 'n. (bits('n), bits('n)) -> bits('n)
overload operator & = {and_bool, and_bits}

val or_bits = {c:"or_bits", _: "or_vec"} : forall 'n. (bits('n), bits('n)) -> bits('n)
overload operator | = {or_bool, or_bits}


overload ~ = {not_bool, not_vec}

val eq_anything = {ocaml: "(fun (x, y) -> x = y)", lem: "eq", coq: "generic_eq", _:"eq_anything"} : forall ('a : Type). ('a, 'a) -> bool
overload operator == = {eq_anything}


val neq_vec = {lem: "neq"} : forall 'n. (bits('n), bits('n)) -> bool
function neq_vec (x, y) = not_bool(eq_bits(x, y))

val neq_anything = {lem: "neq", coq: "generic_neq"} : forall ('a : Type). ('a, 'a) -> bool
function neq_anything (x, y) = not_bool(x == y)

overload operator != = {neq_int, neq_vec, neq_anything}


val add_vec = {c: "add_bits", _: "add_vec"} : forall 'n. (bits('n), bits('n)) -> bits('n)
val add_vec_int = {c: "add_bits_int", _: "add_vec_int"} : forall 'n. (bits('n), int) -> bits('n)
overload operator + = {add_int, add_vec, add_vec_int}

val sub_vec = {c: "sub_bits", _: "sub_vec"} : forall 'n. (bits('n), bits('n)) -> bits('n)
val sub_vec_int = {c: "sub_bits_int", _: "sub_vec_int"} : forall 'n. (bits('n), int) -> bits('n)
overload operator - = {sub_int, sub_vec, sub_vec_int}


/* val reg_index : reg_size -> reg_index */
/* function reg_index x = unsigned(x) */


val quotient_nat = {ocaml: "quotient", interpreter: "quotient", lem: "integerDiv", coq: "ZEuclid.div"} : 
    forall 'M 'N, 'M >= 0 & 'N >= 0. (int('M), int('N)) -> int(div('M,'N))
val quotient = {ocaml: "quotient", interpreter: "quotient", lem: "integerDiv", coq: "ZEuclid.div"} : 
    forall 'M 'N. (int('M), int('N)) -> int(div('M,'N))
overload quot = {quotient_nat, quotient}


val __raw_GetSlice_int = "get_slice_int" : forall 'w, 'w >= 0. (int('w), int, int) -> bits('w)

val __GetSlice_int : forall 'n, 'n >= 0. (int('n), int, int) -> bits('n)
function __GetSlice_int (n, m, o) = __raw_GetSlice_int(n, m, o)

val to_bits : forall 'l, 'l >= 0.(implicit('l), int) -> bits('l)
function to_bits (l, n) = __raw_GetSlice_int(l, n, 0)


val int_power = {ocaml: "int_power", interpreter: "int_power", lem: "pow", coq: "pow", c: "pow_int"} : (int, int) -> int

overload operator ^ = {xor_vec, int_power}


val mask : forall 'l 'm, 'l >= 0 & 'm >= 0. (implicit('l), bits('m)) -> bits('l)
function mask(len, bv) = sail_mask(len, bv)

overload operator % = {emod_int}
overload operator / = {ediv_int}
overload mod = {emod_int}

val print = "print_endline" : string -> unit

val error : forall ('a : Type). string -> 'a effect{escape}
function error(message) = {
  assert(false, message); 
  exit()
}

type min ('M : Int, 'N : Int) = {'O, ('O == 'M | 'O == 'N) & 'O <= 'M & 'O <= 'N. int('O)}


val appendL = {ocaml: "append", interpreter: "append_list", lem: "append_list", coq: "List.app"} : forall ('a:Type). (list('a),list('a)) -> list('a)
