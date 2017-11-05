#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"


staload "libats/ML/SATS/option0.sats"
staload "libats/ML/SATS/basis.sats"
//staload "libats/ML/SATS/list0.sats" //TODO does not work

#include "src/common.dats"
#include "src/shader_utils.dats"
#include "src/util.dats"
#include "src/graphics.dats"



//patscc -o exe ./src/common.dats ./src/main.dats -DATS_MEMALLOC_LIBC -lrt -D_GNU_SOURCE

%{
 GLFWwindow* win_handle = 0; //used as global variable
%}

fun get_win_handle() = 
 $UN.ptr0_get<GLFWwindow>($extval(ptr, "&win_handle"))

local

val def_win_width = 600
val def_win_height = 600
   
in

fun on_resize(win:GLFWwindow, width:int, height:int) : void = 
   glViewport(0,0,width,height)

fn initGL{l : addr}() : void = {
    @glfwInit()
    @glfwWindowHint($extval(int,"GLFW_CONTEXT_VERSION_MAJOR"),3)
    @glfwWindowHint($extval(int,"GLFW_CONTEXT_VERSION_MINOR"),3)
    @glfwWindowHint($extval(int,"GLFW_OPENGL_PROFILE"),
     $extval(int, "GLFW_OPENGL_CORE_PROFILE"))
    
    val null_ = $UN.cast{ptr}(0)
    
    val win_handle = glfwCreateWindow(def_win_width,def_win_height, "win", null_, null_)
    
    @ $UN.ptr0_set<GLFWwindow>($extval(ptr, "&win_handle"), win_handle)
    
    
    @glfwMakeContextCurrent win_handle
    
    @if $UN.cast{ptr}(win_handle) = null_ then
       print "Error initializing window\n"
       
    @gladLoadGLLoader()
    @glfwSwapInterval(1)
       
    
    
    @glfwSetFramebufferSizeCallback(win_handle, on_resize)
    
}    

 
fn initGame() : void = 
{
  val path = "./res/shaders/" //TODO make it crossplatform
  val files = find_all_files_in_dir(path)
  
  
  val files_list = ptr0_to_list0<string>(files.names, files.count)
  val names_list = files_list <* drop_file_extension
  val unique_names_list = list0_remove_duplicates(names_list, eq_string)
  
  @ println!("found these shaders:")
  @ unique_names_list \foreach println
  
  
  val programs = unique_names_list <# (
  lam (x : string) => let
    val pathVert = path ++ x ++ ".vert"
    val pathFrag = path ++ x ++ ".frag"
  in
    loadShader(pathVert, pathFrag)
  end
                                       )
  
  
  
  
}
 
fn loop () : void = {

  val win_handle = get_win_handle()

  fun processInput() : void =
    if glfwGetKey(win_handle, $extval(int, "GLFW_KEY_ESCAPE")) =
     $extval(int, "GLFW_PRESS") then
       glfwSetWindowShouldClose(win_handle, true)
    else
       () 
    
  @cwhile(lam () => not (glfwWindowShouldClose win_handle),
    lam () =>
       let

     in
        begin
          glfwPollEvents();

          processInput();

          glClear($extval(int,"GL_COLOR_BUFFER_BIT"));
          glClearColor(float 1,float 0, float 0,float 1);

          glfwSwapBuffers(win_handle);

        end
     end
  )
  
  @glfwTerminate()
  
}    
 

fn runVoxelized() : void = {
  @print "running...\n"
  
  
  @initGL()
  @initGame()
  @loop ()
  
  @print "done\n"
  
  
}
  
end  //end of [local]
  
  
  
  
  
val _ = runVoxelized()
implement main0 () = ()