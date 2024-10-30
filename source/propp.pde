// LIBRARY FOR PROPP FUNCTIONS
// based on Lakoff elaboration of Propp functions
String[] propp_tooltips = {"Int(erdiction)", "Vio(lation)", "Cv: Complication villany", "L(eave)", "D(onor)", 
                     "hEro reacts", "F: gain magic", "G: uses maGic", "H: figHts villain", "I: defeats vIllain", 
                     "K: misfortune liquidated", "Rew(ard)"};
String[] proppTags = {"Interdiction", "Violation", "Complication", "Leave", "Donor", 
                      "Hero reacts", "Gain magic", "Uses magic", "Fights villain", "Defeats villain", 
                      "Misfortune liquidated", "Reward"};
int max_length_propp_tag = 21; // Misfortune liquidated
int max_length_propp_id = 3; // CoV
// String[] proppIds = {"Int", "Vio", "Cv", "L", "D", "E", "F", "G", "H", "I", "K", "Rew"}; // Lakoff style
String[] proppIds = {"Int", "Vio", "CoV", "Lea", "Don", "HRe", "GaM", "Use", "FiV", "DeV", "MiL", "Rew"};
int cur_unit_propp_tag_index = -1;
float[] propp_layout_x = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
float[] propp_layout_width = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
color[] propp_layout_colors = {color(0), color(0), color(0), color(0), color(0), color(0), color(0), color(0), color(0), color(0), color(0), color(0)};

Propp_function[] propp_functions;
int i_select_pf;

// color of propp function fields (hue 45o, increase saturation 10-90, B 100)
void propp_color_setup() {
  colorMode(HSB, 360, 100, 100);
  float hue = 45; float mid_saturation = 50; float min_saturation = 10; float max_saturation = 90;
  // float saturation_interval = (max_saturation - min_saturation)/propp_tooltips.length;
  for (int i=0; i<propp_tooltips.length; i++) {
    // float saturation = min_saturation + saturation_interval * i;
    float saturation = mid_saturation;
    propp_layout_colors[i]=color(hue,saturation,100);
  }
}

void propp_setup() {
  // propp_function_position_setup();
  propp_functions = new Propp_function[proppTags.length];
  propp_color_setup();
  i_select_pf = -1;
  for (int i=0; i<propp_tooltips.length; i++) {
    propp_layout_width[i] = (actual_width/propp_tooltips.length) - 2*margin;
    propp_layout_x[i] = left_offset+i*(margin+propp_layout_width[i]+margin)+margin+propp_layout_width[i]/2;
    propp_functions[i] = new Propp_function(i);
  //  if (i%2==0) {propp_layout_colors[i] = bg_color_1;} else  {propp_layout_colors[i] = bg_color_2;}
  }  
}

void propp_layout_bg_matrix() {
  noStroke();
  for (int i=0; i<propp_tooltips.length; i++) {
    fill(propp_layout_colors[i]);
    rect(propp_layout_x[i]/zoom-xo, (top_offset+actual_height/2)/zoom-yo,
         propp_layout_width[i], actual_height);
           // actual_width/propp_tooltips.length, actual_height);
    // fill(text_color); textFont(default_font_type); textAlign(CENTER,TOP);
    // text(propp_tooltips[i], propp_layout_x[i]/zoom-xo, (top_offset+default_font_size)/zoom-yo);
  }
}

//// calculation of the propp function button position in the bottom offset
//void propp_function_position_setup() {
//  for (int i=0; i<propp_functions.length; i++) {
//      propp_ids[i].w = state_width; states[i].h = bottom_offset;  // rectangle
//      states[i].x = (left_offset + i*(state_width + margin) + states[i].w/2)/zoom-xo; 
//      states[i].y = (size_y - states[i].h/2)/zoom-yo;
//      states[i].tooltip.x = states[i].x; states[i].tooltip.y = states[i].y;
//    }
//  }
//}

// identify mouse click for a propp function
int propp_function_click() {
  int i_select_aux=-1;
  float x = mouseX; float y = mouseY; // capture mouse position
  for (int i=0; i<propp_functions.length; i++) { // for each propp function 
    if (x < (propp_functions[i].x+propp_functions[i].w/2)*zoom+xo && x > (propp_functions[i].x-propp_functions[i].w/2)*zoom+xo && // if the mouse is over the pf box
        y < (propp_functions[i].y+propp_functions[i].h/2)*zoom+yo && y > (propp_functions[i].y-propp_functions[i].h/2)*zoom+yo) {
        i_select_aux=i; 
    }
  } // END FOR
  return i_select_aux;
}

// mouse selection for a propp function
void pf_selection() {
  int i_select_aux = propp_function_click(); // choose a propp function
  if (i_select_aux!=-1) { // if successful
    if (selection_possible) { // if nothing was selected before
      i_select_pf = i_select_aux; select_type = "PROPP";  propp_functions[i_select_pf].selected = true; selection_possible=false;
    } else 
    if (select_type.equals("PROPP")) { // if previous selection is a propp function
      if (i_select_pf==i_select_aux) { // if same propp function, deselect
        propp_functions[i_select_pf].selected = false; i_select_pf = -1; select_type = "NULL"; selection_possible=true;
      }
    } else
    if (select_type.equals("NODE")) { // if previous selection is a node, allow propp function selection
      i_select_pf = i_select_aux; select_type = "NODE+PROPP"; propp_functions[i_select_pf].selected = true; selection_possible=false;
    }
  } // END PROPP FUNCTION WAS SELECTED
}

// draw state buttons
void draw_propp_functions() {
  // PRP header
  //fill(text_color);
  //flex_write_lines_in_box("PRPs", default_font_name, default_font_aspect_ratio, 
  //                        "CENTER", "CENTER", 
  //                        (left_offset/2)/zoom-xo, (size_y-(bottom_offset)/2)/zoom-yo, left_offset, bottom_offset);  
  for (int i=0; i < propp_functions.length; i++) {
    if ((select_type=="PROPP" || select_type=="NODE+PROPP") && i==i_select_pf) {fill(select_color);} 
    else {fill(propp_functions[i].pf_color);} 
    rectMode(CENTER);
    rect(propp_functions[i].x,propp_functions[i].y,propp_functions[i].w,propp_functions[i].h);
    if ((select_type=="PROPP" || select_type=="NODE+PROPP") && i==i_select_pf) {fill(select_text_color);} 
    else {fill(text_color);}
    flex_write_lines_in_box(propp_functions[i].id, default_font_name, default_font_aspect_ratio, 
                            "CENTER", "CENTER", 
                            propp_functions[i].x, propp_functions[i].y, propp_functions[i].w, propp_functions[i].h);
  }
}



// propp function name layover through tooltip
void pf_layover() {
  // search for the tooltip to display
  float x = mouseX; float y = mouseY; // capture mouse position
  for (int i=0; i<propp_functions.length; i++) { // for each propp function 
    ToolTip tt = propp_functions[i].tooltip; 
    if (x < (propp_functions[i].x+propp_functions[i].w/2)*zoom+xo && x > (propp_functions[i].x-propp_functions[i].w/2)*zoom+xo) { // if the mouse is over such state box
      if (y < (propp_functions[i].y+propp_functions[i].h/2)*zoom+yo && y > (propp_functions[i].y-propp_functions[i].h/2)*zoom+yo) {
        tt.x= x/zoom-xo; tt.y= y/zoom-yo; 
        color c = color(0, 0, 80, 10); 
        tt.setBackground(c); 
        tt.display();
      }
    }
  } // END FOR
} 


// PROPP FUNCTION CLASS DEFINITION
class Propp_function {
  String name;
  int propp_index;
  String id;
  float x,y;
  float w,h;
  float x_min, x_max, y_min, y_max;
  color pf_color;
  boolean selected;
  ToolTip tooltip;
  
  Propp_function (int index) {
    propp_index = index; name = proppTags[index]; id = proppIds[index]; 
    x=propp_layout_x[index]/zoom-xo; y=(size_y-bottom_offset/2)/zoom-yo; w=propp_layout_width[index]; h=bottom_offset; 
    pf_color = propp_layout_colors[index]; selected = false;
    tooltip = new ToolTip(propp_tooltips[index], x, y-w, size_x/2, size_y/2, default_font_name, default_font_size, default_font_aspect_ratio);
  }

} // END CLASS STATE
