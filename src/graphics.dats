#ifndef GRAPHICS_ATS
#define GRAPHICS_ATS
#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"


%{#
//
//#ifndef GRAPHICS_GLADLOADER
//#define GRAPHICS_GLADLOADER
#include "glad/glad.h"
#include "GLFW/glfw3.h"

void _gladLoadGLLoader();
//#endif
//
%}

typedef GLFWwindow = $extype"GLFWwindow*"
typedef char_ptr_ptr = $extype"char**"
typedef const_char_ptr_const_ptr = $extype "const char * const*"
typedef int_ptr = $extype"int*"

val GLFW_TRUE  = $extval(int,"GLFW_TRUE")
val GLFW_FALSE = $extval(int, "GLFW_FALSE")
val GLFW_PRESS = $extval(int, "GLFW_PRESS")
val GL_COLOR_BUFFER_BIT = $extval(int, "GL_COLOR_BUFFER_BIT")
val GL_CURRENT_PROGRAM = $extval(int, "GL_CURRENT_PROGRAM")

extern fun
gladLoadGLLoader : 
() -> void = "mac#_gladLoadGLLoader"

extern fun 
glfwInit : 
() -> void = "mac#glfwInit"

extern fun 
glfwWindowHint : 
(int, int) -> void = "mac#glfwWindowHint"

extern fun
glfwCreateWindow : 
(int, int, string, ptr, ptr) -> GLFWwindow = "mac#glfwCreateWindow"

extern fun
glfwMakeContextCurrent :
(GLFWwindow) -> void = "mac#glfwMakeContextCurrent"

extern fun
__gladLoadGLLoader :
(string->void) -> int = "mac#gladLoadGLLoader"

typedef GLADloadproc = $extype"GLADloadproc"
typedef GLFWframebuffersizefun = $extype"GLFWframebuffersizefun"
//ptr->int->int->void


extern fun
glViewport :
(int,int,int,int) -> void = "mac#glViewport"

extern fun
glfwSetFramebufferSizeCallback :
(GLFWwindow, (GLFWwindow,int,int) -<fun1> void) -> void = "mac#glfwSetFramebufferSizeCallback"

extern fun
glfwWindowShouldClose :
(GLFWwindow) -> bool = "mac#glfwWindowShouldClose"

extern fun
glfwTerminate :
() -> void = "mac#glfwTerminate"

extern fun
glfwSwapBuffers :
(GLFWwindow) -> void = "mac#glfwSwapBuffers"


extern fun
glfwSetWindowShouldClose :
(GLFWwindow, bool) -> void = "mac#glfwSetWindowShouldClose"

extern fun
glfwGetKey :
(GLFWwindow, int) -> int = "mac#glfwGetKey"

extern fun
glfwPollEvents :
() -> void = "mac#glfwPollEvents"

extern fun
glClear :
(int) -> void = "mac#glClear"


extern fun
glfwSwapInterval :
(int) -> void = "mac#glfwSwapInterval"

extern fun 
glClearColor :
(float, float, float, float) -> void = "mac#glClearColor"

extern fun
glGetIntegerv :
{l : agz}(!int @ l |int, ptr l) -> void = "mac#glGetIntegerv"

extern fun
glUseProgram :
(int) -> void = "mac#glUseProgram"

extern fun
glUniformMatrix4fv :
{l : agz}(!array_v(float, l, 16) | int, int, bool, ptr l) -> void = "mac#glUniformMatrix4fv"


extern fun
glShaderSource :
(int, int, const_char_ptr_const_ptr, int_ptr) -> void = "mac#glShaderSource"

extern fun
glCreateProgram :
() -> int = "mac#glCreateProgram"

extern fun
glCreateShader :
(int) -> int = "mac#glCreateShader"

extern fun
glCompileShader :
(int) -> void = "mac#glCompileShader"

extern fun
glGetShaderiv :
{l : agz}(!int? @ l | int, int, ptr l) -> void = "mac#glGetShaderiv"

extern fun
glAttachShader :
(int, int) -> void = "mac#glAttachShader"

extern fun
glLinkProgram :
(int) -> void = "mac#glLinkProgram"

extern fun
glValidateProgram :
(int) -> void = "mac#glValidateProgram"

extern fun
glGetShaderInfoLog :
(int, int, ptr, !strptr) -> void = "mac#"


#endif