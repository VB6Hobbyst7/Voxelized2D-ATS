#ifndef COMMON_ATS
#define COMMON_ATS
#define ATS_DYNLOADFLAG 0

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

staload UN = "prelude/SATS/unsafe.sats"

staload "libats/ML/SATS/basis.sats"
staload "libats/ML/SATS/option0.sats"



//HELP=====================================================
//@[T][N] - viewtype of array, can be stackallocated,
//same as array_v(a,l,n)


//cfor<int><void>(0, #< 5, int_inc, lam i => ...)

//==========================================================

//=================C BINDINGS===============================

extern 
fun timeMs : () -> double = "ext#time_ms"


extern fun
c_double_to_string :
(double, int) -> ptr = "ext#c_double_to_string"

extern fun
c_int_to_string :
(int, int) -> ptr = "ext#c_int_to_string"


//===========================================================

//CONVERSIONS ===============================================

//g0int2float_int_double
//$UN.cast
//$UN.castvwtp0

//postfix f //works as float literal
fun int_to_float(i : int) : float = $UN.cast{float}(i)
fun double_to_float(d : double) : float = $UN.cast{float}(d)

//r for readonly (uses castvwtp1)
fn strptr_to_string_r(ptr: !strptr) : string = $UN.castvwtp1{string}(ptr)
fn ptr_to_strptr(ptr : ptr) : strptr = $UN.castvwtp1{strptr}(ptr)

//overload f with int_to_float
//overload f with double_to_float

//===========================================================

//MISC=======================================================
fn int_less_then(a : int)(b : int) : bool = b < a
fn int_inc = lam (i : int) =<cloref1> i + 1

prefix #<
overload #< with int_less_then

fun{a:t@ype} make_null() : a = $UN.cast{a}(0)


//===========================================================

//ALLOCATION=================================================
extern fun 
mallocBytes{n : nat}(n: int n) :
[l : agz] (array_v(char?, l, n) | ptr l) =
  "mac#malloc"
  
extern fun 
malloc_gc_bytes0(n: int) :
(ptr) =
  "mac#GC_malloc"

extern fun malloc_free(str: strptr) : void = "mac#free"

extern fun
free0(p : ptr) : void = "mac#free"
//===========================================================


//STRING ====================================================
fun string0_get_at(str : string, i : int) : char = //does not work
let
  val ptr = string2ptr(str)
  
in
  $UN.ptr0_get_at_int<char>(ptr, i)
end

fun eq_string(a : string, b : string) : bool =
  strcmp(a, b) = 0

//===========================================================

//FUNCTIONAL=================================================


fun {a : t0p}{b : t0p} list0_map_fun (xs : list0(INV(a)), func : INV(a -> b)) : list0 b =
  case+ xs of
  | list0_cons(x, xs) => list0_cons(func x, list0_map_fun(xs, func))
  | _ => list0_nil
  
fun {a : t0p}{b : t0p} list0_map_clo (xs : list0(INV(a)), func : INV(a -<cloref1> b)) : list0 b =
  case+ xs of
  | list0_cons(x, xs) => list0_cons(func x, list0_map_clo(xs, func))
  | _ => list0_nil
  
fun {a : t0p} list0_foreach_fun (xs : list0(INV(a)), func : a -> void) : void =
  case+ xs of
  | list0_cons(x, xs) => (func x; list0_foreach_fun(xs, func))
  | _ => ()
  
fun {a : t0p}{b : t0p} list0_foldl_fun(xs : list0(INV(a)), e : b, func : (b,a) -> b) : b =
  case+ xs of
  | list0_cons(x,xs) => list0_foldl_fun(xs, func(e,x), func)
  | list0_nil() => e 
fun {a : t0p}{b : t0p} list0_foldl_clo(xs : list0(INV(a)), e : b, func : (b,a) -<cloref1> b) : b =
  case+ xs of
  | list0_cons(x,xs) => list0_foldl_clo(xs, func(e,x), func)
  | list0_nil() => e 

fun {a : t@ype} list0_elem (xs : list0(INV(a)), e : INV(a), eq : (a,a) -> bool) : bool =
  case+ xs of
  | list0_cons(x, xs) => if eq(x, e) then true else list0_elem(xs, e, eq)
  | list0_nil() => false 

fun {a : t0p} list0_remove_duplicates(xs : list0(INV(a)), eq : (a,a) -> bool) : list0 a =
  list0_foldl_clo<a><list0 a>(xs, list0_nil(), lam(seen, x) =<cloref1> if list0_elem(seen, x, eq) then seen else list0_cons(x,seen))

fun {a:t0ype} ptr0_foreach_fun (p : ptr, len : INV(int), func : a -> void) : void =
let
  fun loop (i : int) =
    if i < len then
      let
        val v = $UN.ptr0_get_at_int<a>(p, i)
        val _ = func v
      in
        loop(i + 1)
      end
    else
      ()
in  
  loop 0
end






fun ptr0_foreach_p{a : type} (p : ptr, len : INV(int), func : a -<cloref1> void) : void =
let
  fun loop (i : int) =
    if i < len then
      let
        val v = $UN.ptr0_get_at_int<a>(p, i)
        val _ = func v
      in
        loop(i + 1)
      end
    else
      ()
in  
  loop 0
end

fun{a:t0ype} ptr0_to_list0 (p : ptr, len : INV(int)) : list0 a =
let
  fun loop (i : int, list : list0 a ) : list0 a =
    if i < len then
      let
        val v = $UN.ptr0_get_at_int<a>(p,i)
        val cons = list0_cons(v, list) 
      in
        loop (i + 1, cons)
      end
    else
      list
in
  loop(0, list0_nil())
end

//symintr map
overload map with list0_map_clo

//symintr <$>
infixl <#
infixl <*

overload <# with list0_map_clo
overload <* with list0_map_fun

symintr foreach
overload foreach with list0_foreach_fun

//===========================================================

fun println(str: string) : void = (print str;print_newline())

fun double_to_string
(x : double, max_size : int) : string =
  let
    val ptr = $UN.castvwtp0{Strptr1}(c_double_to_string (x, max_size) )
    val copy = strptr1_copy(ptr)
    val () = free ptr
  in
    $UN.castvwtp0{string}(copy)
  end
 
fun int_to_string
(x : int, max_size : int) : string =
  let
    val ptr = $UN.castvwtp0{Strptr1}(c_int_to_string (x, max_size) )
    val copy = strptr1_copy(ptr)
    val () = free ptr
  in
    $UN.castvwtp0{string}(copy)
  end   




fn {a:type}timed (printer : double -> string, f : () -> a) : a =
  let
    val t1 = timeMs()
    val res = f ()
    val t2 = timeMs()
    val str = printer (t2 - t1)
    val () = (print str; print_newline())
  in
    res
  end 

fn{a:t@ype} float(x:a):float = $UN.cast{float}(x)
fn{a:t@ype} double(x:a):double = $UN.cast{double}(x)
fn{a:t@ype} int(x:a):int = $UN.cast{int}(x)


fn reg_string_append(a : string, b : string) : string = 
  $UN.castvwtp0{string} ( string0_append(a,b) )
  
infixl (+) ++
overload ++ with reg_string_append

fun {a:t@ype}{b:t@ype}cfor(i : a, cond : a -<cloref1> bool, transformer : a -<cloref1> a, body : a -<cloref1> b) : void = 
  if cond i then let 
      val _ = body i
    in  
      cfor(transformer i, cond, transformer, body)
    end  
  else
    ()
    
//tail-recursive    
fun cwhile(cond : () -<cloref1> bool, body : () -<cloref1> void) : void = 
  if cond() then 
    let 
      val () = body()
    in  
      cwhile(cond, body)
    end  
  else
    ()

fn print_nl() = let val () = print("\n") in end //does not work, why ??



typedef
fdouble = double -<cloref1> double
//
macdef epsilon = 1E-6 (* precision *)
//
// [f1] is the derivative of [f]
//
fun
newton_raphson
(
  f: fdouble, f1: fdouble, x0: double
) : double = let
  fun loop (
    f: fdouble, f1: fdouble, x0: double
  ) : double = let
    val y0 = f x0
  in
    if abs (y0 / x0) < epsilon then x0 else
      let val y1 = f1 x0 in loop (f, f1, x0 - y0 / y1) end
    // end of [if]
  end // end of [loop]
in
  loop (f, f1, x0)
end // end of [newton_raphson]

// square root function
fn sqrt_double (c: double): double =
  newton_raphson (lam x => x * x - c, lam x => 2.0 * x, 1.0)
// cubic root function
fn cbrt_double (c: double): double =
newton_raphson (lam x => x * x * x - c, lam x => 3.0 * x * x, 1.0)

fun {a : t@ype}swap{l1,l2:addr}(proof1 : !a @ l1, proof2 : !a @ l2 |
 p1 : ptr (l1), p2 : ptr(l2)) : void = let
 val x = !p1
 val () = !p1 := !p2
 val () = !p2 := x
 in end

extern fun{a:t@ype}
plus(x : INV(a), y : INV(a)) : a

extern fun{a:t@ype}
minus(x : INV(a), y : INV(a)) : a

extern fun{a:t@ype}
mult(x : INV(a), y : INV(a)) : a

extern fun{a:t@ype}
sqrt(x : INV(a)) : a

extern fun{a:t@ype}
fromDouble(x : double) : a

implement sqrt<double>(x) = sqrt_double x
implement fromDouble<double>(x) = x

extern fun{a:t@ype}
one() : a

extern fun{a:t@ype}
zero() : a

implement zero<int>() = 0
implement zero<double>() = 0.0

implement one<int>() = 1
implement one<double>() = 1.0

implement plus<int>(x,y)     = x + y
implement plus<double>(x,y)  = x + y
implement plus<float>(x,y)   = x + y

implement minus<int>(x,y)    = x - y
implement minus<double>(x,y) = x - y
implement minus<float>(x,y)  = x - y

implement mult<int>(x,y) = x * y
implement mult<double>(x,y) = x * y

infix (+) #+#
infix (-) #-#
infix ( * ) #*#
overload #+# with plus
overload #-# with minus
overload #*# with mult


fun{a:t@ype}
list_vt_plus
{n:nat}
(xs : !list_vt(INV(a),n), ys : !list_vt(INV(a),n)) :
list_vt(a,n) =
case+ (xs,ys) of
| (list_vt_nil(), list_vt_nil()) => list_vt_nil()
| (list_vt_cons(x,xs), list_vt_cons(y,ys)) => list_vt_cons(plus<a>(x,y), list_vt_plus<a>(xs,ys))


fun{a:t@ype}
list_vt_minus
{n:nat}
(xs : !list_vt(INV(a),n), ys : !list_vt(INV(a),n)) :
list_vt(a,n) =
case+ (xs,ys) of
| (list_vt_nil(), list_vt_nil()) => list_vt_nil()
| (list_vt_cons(x,xs), list_vt_cons(y,ys)) => list_vt_cons(minus<a>(x,y), list_vt_minus<a>(xs,ys))


fun{a:t@ype}
list_plus
{n:nat}
(xs : list(INV(a),n), ys : list(INV(a),n)) :
list(a,n) =
case+ (xs,ys) of
| (list_nil(), list_nil()) => list_nil()
| (list_cons(x,xs), list_cons(y,ys)) => list_cons(plus<a>(x,y), list_plus<a>(xs,ys))


fun{a:t@ype}
list_minus
{n:nat}
(xs : list(INV(a),n), ys : list(INV(a),n)) :
list(a,n) =
case+ (xs,ys) of
| (list_nil(), list_nil()) => list_nil()
| (list_cons(x,xs), list_cons(y,ys)) => list_cons(minus<a>(x,y), list_minus<a>(xs,ys))

fn {a:t@ype}list_cross
(xs : list(a,3), ys : list(a,3)) : list(a,3) =
case+ (xs,ys) of
|( list_cons(x1,list_cons(x2, list_cons(x3, list_nil))), 
   list_cons(y1,list_cons(y2, list_cons(y3, list_nil))) ) =>
     list_cons(x2 #*# y3 #-# y2 #*# x3, list_cons(y1 #*# x3 #-# x1 #*# y3, list_cons(x1 #*# y2 #-# x2 #*# y1, list_nil)))

datatype triangle(a:t@ype,int) =
 |{n:nat}triangle (a,n) of (list(a,n), list(a,n), list(a,n)) 
 
fn {a:t@ype}triangle_p1{n:nat}(tri : triangle(a,n)) : list(a,n) =
   case+ tri of
   |triangle(p1,_,_) => p1
fn {a:t@ype}triangle_p2{n:nat}(tri : triangle(a,n)) : list(a,n) =
   case+ tri of
   |triangle(_,p2,_) => p2
fn {a:t@ype}triangle_p3{n:nat}(tri : triangle(a,n)) : list(a,n) =
   case+ tri of
   |triangle(_,_,p3) => p3
   
fun {a:t@ype}list_dot{n:nat}(xs : list(a,n), ys : list(a,n)) : a =
   case+ (xs,ys) of
   | (list_cons(x,xs), list_cons(y,ys)) => x #*# y #+# list_dot<a>(xs,ys)
   | (list_nil(), list_nil()) => zero<a>() 


fun {a:t@ype}list_replicate{n:nat}(n : int n, a : a) : list(a,n) =
  let
    fun loop{i:nat}(i : int i, xs : list(a, i)) : list(a,n) = 
      if i = n then
        xs
      else
        loop(i + 1, list_cons(a, xs))
  in
    loop(0, list_nil())
  end
//implement(a) minus<List0(a)>(x,y) = list_minus<a>(x,y)


fun {a:t@ype}{b:t@ype} option_map(f : INV(a) -<cloref1> b, opt : Option (INV(a))) : Option b =
  case+ (opt) of
  |Some(x) => Some(f x)
  |None() => None()

fun {a:t@ype}{b:t@ype} option0_map(f : INV(a) -<cloref1> b, opt : option0 (INV(a))) : option0 b =
  case+ (opt) of
  |Some0(x) => Some0(f x)
  |None0() => None0()


fun {a:t@ype}
arr_dot{n:nat | n > 0}{l1,l2 : addr} 
               (
                A : !arrayptr(a,l1,n),
                B : !arrayptr(a,l2,n),
                n : int n ) : a = let
  
  fun {a:t@ype}loop {i:nat | i < n}{l1,l2: addr}
  (A : !arrayptr(a,l1,n),
   B : !arrayptr(a,l2,n),
   i : int i,
   n : int n,
   r : a) : a = 
  let
    val x = arrayptr_get_at_gint<a>(A, i)
    val y = arrayptr_get_at_gint<a>(B, i)
    val arg = x #*# y #+# r              
  in
    if i = 0 then arg else loop(A,B, i - 1, n, arg)  
  end
  
  in
  
  loop(A, B, n - 1, n, zero<a>())
  
  end


//overload map with option0_map
overload map with option_map


overload - with list_minus

symintr cross
symintr dot

overload cross with list_cross
overload dot with list_dot

fn {a:t@ype}triangle3_area(tri : triangle(a,3)) : a = 
   case+ tri of |triangle(p1,p2,p3) => let
     val d1 = p2 - p1
     val d2 = p3 - p1
     val t1 = cross(d1,d2)
     val t2 = dot(t1,t1)
    in
     
     fromDouble<a>(0.5) #*# sqrt t2
    end
    
    
#endif