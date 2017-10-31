#ifndef UTIL_ATS
#define UTIL_ATS

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"




#include "src/common.dats"

%{#
#ifndef UTIL_C
#define UTIL_C
#include <util.h>

#endif
%}


typedef filenames = $extype_struct"filenames" of {names= ptr, count= int}

extern fun
readFile :
(string) -> strptr = "mac#"


//do not free the result (it is garbage collected)
extern fun
find_all_files_in_dir :
(string) -> filenames = "mac#"


fun drop_file_extension(str : string) : string =
let
  
  fun loop(i : int) : int = 
  let
    val ptr = string2ptr(str)
    val char = $UN.ptr0_get_at_int<char>(ptr, i)
      
  in
    if char <> '.' && char <> '\0' then loop (i + 1) else i
  end
  
  val len = loop 0
  
  
  val bytes = malloc_gc_bytes0(len + 1)
  
  
  fun loop2(i : int) : void = 
    if i < len then
      let
        val ptr = string2ptr(str)
        val () = $UN.ptr0_set_at_int<char>(bytes, i, $UN.ptr0_get_at_int<char>(ptr, i))
      in
        loop2 (i + 1)
      end
    else
      ()
  
  val () = loop2 0
  
  val () = $UN.ptr0_set_at_int<char>(bytes, len, '\0')
  
  
  
  
in
  $UN.cast{string}(bytes)
end

#endif