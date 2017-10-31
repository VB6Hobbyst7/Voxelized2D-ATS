#ifndef RENDER_ATS
#define RENDER_ATS

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

dataview render_data =
  | render_data of ( ()->void ) //deconstruction function
  
//custom destructor for render_data
  

typedef render_vert_frag = 
  '{ construct= ()-> render_data, deconstruct=()->void}

#endif