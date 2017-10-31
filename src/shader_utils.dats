#ifndef SHADER_UTILS_ATS
#define SHADER_UTILS_ATS
#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"


#include "src/graphics.dats"
#include "src/util.dats"
#include "src/common.dats"

typedef Shader = @{ id=int }

fn isInUse (shader : Shader) : bool =
let
  var result : int = 0
  val _ = glGetIntegerv(view@result | $extval(int,"GL_CURRENT_PROGRAM"), addr@result )
in
  result = shader.id
end

fn enable (shader : Shader) : bool =
let
  val using = isInUse shader
in
  if using then false
  else
    (glUseProgram shader.id; true)
end

fn disable (shader : Shader) : bool =
let
  val using = isInUse shader
in
  if using then
    (glUseProgram 0; true)
  else false
end

fn setMat4{l : agz}(pf : !array_v(float, l, 16) | shader : Shader, transpose : bool, mat : ptr l) : void =
  glUniformMatrix4fv(pf | shader.id, 1,  transpose, mat)
  
fn loadShader (vertPath : string, fragPath : string) : int =
let
  var vertSrc = readFile vertPath
  var fragSrc = readFile fragPath
  
  //val () = println! fragSrc
  
  val prog = glCreateProgram()
  
  
  val vertId = glCreateShader($extval(int, "GL_VERTEX_SHADER"))
  val fragId = glCreateShader($extval(int, "GL_FRAGMENT_SHADER"))
  
  val () = println! 12
  
  var len_1 : int = 1
  
  val () = glShaderSource(vertId, 1, 
    $UN.cast{..}(addr@vertSrc), $UN.cast{..}(addr@len_1))
    
  val () = println! 13
    
  val () = glShaderSource(fragId, 1, 
    $UN.cast{..}(addr@fragSrc), $UN.cast{..}(addr@len_1))
  
  val () = glCompileShader vertId
  
  var status : int
  
  val () = println! 0
  
  val () = glGetShaderiv(view@status |
    vertId, $extval(int, "GL_COMPILE_STATUS"), addr@status) 
  
  val () = println! 1
  
  val () = 
    if ($UN.cast{int}(status) = 0) then 
      let
        var buf = @[char][512]() //stack allocated
        val log = $UN.castvwtp0{strptr}(buf)
        val () = glGetShaderInfoLog(vertId, 512, make_null<ptr>(), 
          log)
        val () = println!("Cannot load vertex shader:\n", log)
        val _ = $UN.castvwtp0{string}(log)
      in
    
      end
    else
      let 
        var status : int
        val () = glCompileShader fragId
        val () = glGetShaderiv(view@status | 
          fragId, $extval(int, "GL_COMPILE_STATUS"),
            addr@status)

        val () =
         if ($UN.cast{int}(status) = 0) then
           let
             var buf = @[char][512]()
             val log = $UN.castvwtp0{strptr}(buf)
             val () = glGetShaderInfoLog(fragId, 512, make_null<ptr>(),
               log)

             val () = println!("Cannot load fragment shader:\n", log)
             val _ = $UN.castvwtp0{string}(log)  
           in

           end
         else
           let
             val () = glAttachShader(prog, vertId)
             val () = glAttachShader(prog, fragId)
             val () = glLinkProgram prog
             val () = glValidateProgram prog
           in

           end
       

      in

      end
  
    
    
  
  val () = malloc_free vertSrc
  val () = malloc_free fragSrc
in
  prog
end

#endif