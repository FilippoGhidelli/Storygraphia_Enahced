// =================================================================================================
// DRAMATIC TENSION (integer number between 1 and 100) 
int min_tension = 1; int max_tension = 100; 
PImage tension_bg;
int cur_unit_tension_index = -1;

void tension_bg_setup() {
  tension_bg = loadImage("tension_90.png"); // loadImage("tension.png");
}

float tension_position(int tension) {
  float y = -1; int tension_interval = max_tension-min_tension;
  float y_relative = (tension * actual_height) / tension_interval;
  y = top_offset + (actual_height - y_relative);
  return y;
}

void tension_layout_update(String tension_name) {
  // println("tension_layout_update");
  for (int i=0; i<i_cur_node; i++) {
    Unit u = (Unit) nodes[i]; 
    if (u.unit_tension_name.equals(tension_name)) {
      Tension t = search_tension(u.unit_tension_name);
      u.y = tension_position(t.tension_value)/zoom-yo;
    }
  }
}

void tension_layout_bg() {
  image(tension_bg, (left_offset+actual_width/2)/zoom-xo, (top_offset+actual_height/2)/zoom-yo, actual_width, actual_height);
}

// LIBRARY FOR TENSIONS

Tension[] tensions;
String[] tension_ids; int tension_id_suffix = 0; // tension id's are printed in the tension box
int total_tensions;
int i_cur_tension;
int i_select_tension;

void tensions_settings() {
  total_tensions = 1000;
}

void tensions_setup() {
  i_cur_tension = 0;
  i_select_tension = -1;
  tensions = new Tension[total_tensions];
  tension_ids = new String[total_tensions];
}

// color of a tension button (on inverse intensity +y +dark)  1 -> 90; 100 -> 50; 50 -> 70
color tension_color_calculation(float y) {
  colorMode(HSB, 360, 100, 100);
  color c = color(0,0,0);
  float min_B = 50; float max_B = 90; // brightness: 50 max tension; 90 min tension 
  c = color(0,0,max_B-(y*(max_B-min_B))/100); // inverse proportional brightness
  return c;
}

// calculation of the tension button position along the bottom offset
void tensions_position_setup() {
  if (i_cur_tension>0) {
    float tension_width = actual_width / i_cur_tension; // computes box width
    if (tension_width >= left_offset) {tension_width=left_offset;} // not more than left_offset
    for (int i=0; i < i_cur_tension; i++) {
      tensions[i].w = tension_width; 
      tensions[i].h = bottom_offset; // tension_height; 
      tensions[i].x = (left_offset + (tension_width + margin)*(i + 0.5))/zoom-xo;
      tensions[i].y = (size_y - bottom_offset/2)/zoom-yo; 
      tensions[i].tooltip.x = tensions[i].x; tensions[i].tooltip.y = tensions[i].y;
    }
  }
}

void update_tension_lists(String tension_name, int value, String mode) {
  // println("update_tension_lists: " + tension_name + ", of " + i_cur_tension + " tensions");
  // print ("\n tensions_checkbox items: "); for (int i=0; i<tensions_checkbox.getItems().size(); i++) {print(tensions_checkbox.getItem(i).getName() + " ");} print("\n");
  switch (mode) {
    case("ADD"):
      if (search_tension(tension_name)==null) {
        tensions[i_cur_tension] = new Tension(tension_name, value);
        // tensions_checkbox.addItem(tension_name, i_cur_tension_checkbox++);
        i_cur_tension++;
      }
    break;
    case("DEL"): // removing a tension button and tension labeling of a node (it should remove from checkbox)
      Tension[] tensions_aux = new Tension[i_cur_tension-1]; String[] tension_ids_aux = new String[i_cur_tension-1];
      int index = search_tension_index(tension_name);
      if (index!=-1) {
        // REMOVING FROM CHECKBOX DOES NOT WORK!
        //println(tensions_checkbox.getItems());
        //for (int i=0; i<tensions_checkbox.getItems().size(); i++) {println(tensions_checkbox.getItem(i).getName());} 
        // tensions_checkbox.deactivate(tension_name);
        // tensions_checkbox.removeItem(tension_name);
        // println(tensions_checkbox.getItems());
        for (int i=0; i<index; i++) {tensions_aux[i]=tensions[i]; tension_ids_aux[i]=tension_ids[i];}
        for (int i=index; i<i_cur_tension-1; i++) {tensions_aux[i]=tensions[i+1]; tension_ids_aux[i]=tension_ids[i+1];}
        for (int i=0; i<tensions_aux.length; i++) {tensions[i]=tensions_aux[i]; tension_ids[i]=tension_ids_aux[i];}
        i_cur_tension--;
      }
    break;
  } // END SWITCH
  tensions_position_setup();
  // println("update_tension_lists: " + i_cur_tension + " tensions");
}

// mouse click on a tension button
int tension_click() {
  int i_select_aux=-1;
  float x = mouseX; float y = mouseY; // capture mouse position
  for (int i=0; i<i_cur_tension; i++) { // for each tension 
    if (x < (tensions[i].x+tensions[i].w/2)*zoom+xo && x > (tensions[i].x-tensions[i].w/2)*zoom+xo && // if the mouse is over the tension box
        y < (tensions[i].y+tensions[i].h/2)*zoom+yo && y > (tensions[i].y-tensions[i].h/2)*zoom+yo) {
        i_select_aux=i; 
    }
  } // END FOR
  return i_select_aux;
}

// selection of a tension button
void tension_selection() {
  int i_select_aux = tension_click(); // choose a tension
  if (i_select_aux!=-1) { // if successful
    if (selection_possible) { // if nothing was selected before
      i_select_tension = i_select_aux; select_type = "TENSION";  selection_possible=false;
    } else 
    if (select_type.equals("TENSION")) { // if previous selection is a tension
      if (i_select_tension==i_select_aux) { // if same tension, deselect
        i_select_tension = -1; select_type = "NULL";  selection_possible=true;
      }
    } else
    if (select_type.equals("NODE")) { // if previous selection is a node, allow agent selection
      i_select_tension = i_select_aux; select_type = "NODE+TENSION";  selection_possible=false;
    }
  } // END tension WAS SELECTED
}


// draw tension buttons
void draw_tensions() {
  // tensions header
  //fill(text_color);
  //flex_write_lines_in_box("TNSs", default_font_name, default_font_aspect_ratio, 
  //                        "CENTER", "CENTER", 
  //                        (left_offset/2)/zoom-xo, (size_y-(bottom_offset)/2)/zoom-yo, left_offset, bottom_offset);  
  // list of tensions
  for (int i=0; i < i_cur_tension; i++) {
    // if the tension is not deleted, draw its button, with name
    if (!tensions[i].deleted) {
      if ((select_type=="TENSION"||select_type=="NODE+TENSION") && i==i_select_tension) {fill(select_color);}
      else {fill(tensions[i].tension_color);} 
      rectMode(CENTER);
      rect(tensions[i].x,tensions[i].y,tensions[i].w,tensions[i].h);
      if ((select_type=="TENSION"||select_type=="NODE+TENSION") && i==i_select_tension) {fill(select_text_color);} 
      else {fill(text_color);}
      flex_write_lines_in_box(tensions[i].id, default_font_name, default_font_aspect_ratio, 
                              "CENTER", "CENTER", 
                              tensions[i].x, tensions[i].y, tensions[i].w, tensions[i].h);
      // draw a dashed line with the tension value
      strokeWeight(1); stroke(0,0,80);
      // line(left_offset/zoom-xo, tension_position(tensions[i].tension_value)/zoom-yo, (left_offset+actual_width)/zoom-xo, tension_position(tensions[i].tension_value)/zoom-yo);
      dash.line(left_offset/zoom-xo, tension_position(tensions[i].tension_value)/zoom-yo, (left_offset+actual_width)/zoom-xo, tension_position(tensions[i].tension_value)/zoom-yo);
      textAlign(LEFT,BOTTOM); fill(0,0,30); textSize(default_font_size);
      text(str(tensions[i].tension_value), left_offset/zoom-xo, tension_position(tensions[i].tension_value)/zoom-yo);
    }
  }
}

// search functions on tensions
Tension search_tension(String tension_name) {
  for (int i=0; i<i_cur_tension; i++) {
    if (tensions[i].name.equals(tension_name)) {return tensions[i];} 
  }
  return null;
}

int search_tension_index(String tension_name) {
  for (int i=0; i<i_cur_tension; i++) {
    if (tensions[i].name.equals(tension_name)) {return i;} 
  }
  return -1;
}

//void initialize_tension_list(String[] tension_list) {
//  for (int i=0; i<tension_list.length; i++) {
//    tension_list[i]="NULL tension";
//  }
//}

String create_tension() {
  String tension_aux = showInputDialog("Please enter new tension");
  if (tension_aux == null || "".equals(tension_aux))
    showMessageDialog(null, "Empty tension!!!", "Alert", ERROR_MESSAGE);
  else if (search_tension(tension_aux)!=null)
    showMessageDialog(null, "ID \"" + tension_aux + "\" exists already!!!", "Alert", ERROR_MESSAGE);
  else {
    showMessageDialog(null, "ID \"" + tension_aux + "\" successfully added!!!", "Info", INFORMATION_MESSAGE);
    // update_tension_lists(tension_aux, "ADD");
  }
  return tension_aux;
}
  
//// PROBABLY USELESS --- SETUP USED, BUT x_min, ... NOT USED
//void tensions_areas_setup() {
//  if (i_cur_tension>0) {
//    float tension_area_width = (size_x-left_offset) / i_cur_tension;
//    if (tension_area_width <= diameter_size) {diameter_size = tension_area_width;} 
//    for (int i=0; i < i_cur_tension; i++) {
//      tensions[i].x_min = left_offset + i*tension_area_width; tensions[i].x_max = tensions[i].x_min + tension_area_width;
//      tensions[i].y_min = top_offset; tensions[i].y_max = size_y;
//    }
//  }
//}

// create new identifier for tension label on button
String create_tension_id(String new_name) { // creates id's (3 letters) for tensions
  boolean id_ok = false; String id_aux = "NULL"; 
  String suffix = str(tension_id_suffix); if (suffix.length()==1) {suffix = "0"+suffix;}
  int index1=0, index2=1, index3=2;
  while (!id_ok) {
    // proposal
    if (new_name.length()>=3) {id_aux = str(new_name.charAt(index1)) + str(new_name.charAt(index2)) + str(new_name.charAt(index3++));}
    else if (new_name.length()>=2) {id_aux = str(new_name.charAt(index1)) + str(new_name.charAt(index2++)) + str(0);}
    else if (new_name.length()>=1) {id_aux = str(new_name.charAt(index1)) + str(0) + str(0);}
    // disposal
    if (searchStringIndex(id_aux, tension_ids, 0, i_cur_tension)==-1) {
      id_ok=true;
    }
  }
  println("NEW tension ID = " + id_aux);
  return id_aux;
}  

// tension name layover through tooltip
void tension_layover() {
  // search for the tooltip to display
  float x = mouseX; float y = mouseY; // capture mouse position
  for (int i=0; i<i_cur_tension; i++) { // for each tension 
    ToolTip tt = tensions[i].tooltip; 
    if (x < (tensions[i].x+tensions[i].w/2)*zoom+xo && x > (tensions[i].x-tensions[i].w/2)*zoom+xo) { // if the mouse is over such state box
      if (y < (tensions[i].y+tensions[i].h/2)*zoom+yo && y > (tensions[i].y-tensions[i].h/2)*zoom+yo) {
        tt.x= x/zoom-xo; tt.y= y/zoom-yo; 
        color c = color(0, 0, 80, 10); // color(0, 80, 255, 30);
        tt.setBackground(c); // color(0,80,255,30));
        tt.display();
      }
    }
  } // END FOR
} 

// tension CLASS DEFINITION
class Tension {
  String name;
  String id;
  float x,y;
  float w,h;
  float x_min, x_max, y_min, y_max;
  color tension_color;
  boolean deleted;
  int tension_value; // 1-100
  ToolTip tooltip;
  
  Tension (String _name, int _tension_value) {
    name = _name; x=-1; y=-1; w=right_offset; h=diameter_size; deleted = false;
    tension_value = _tension_value;
    tension_color = tension_color_calculation(tension_value); // medium value
    tooltip = new ToolTip(name+"-"+str(tension_value), x, y-w, size_x/2, size_y/2, default_font_name, default_font_size, default_font_aspect_ratio);
    id = create_tension_id(name); tension_ids[i_cur_tension]=id;
  }
 
  void modify_tension_value() {    
    int n = int(showInputDialog("Please enter tension value [1-100]:", tension_value)); 
    if (n < 1 || n > 100) {
      showMessageDialog(null, "Invalid value!!!", "Alert", ERROR_MESSAGE);
    } else {
      if (tension_value!=n) {showMessageDialog(null, "Tension value \"" + n + "\" successfully modified!!!", "Info", INFORMATION_MESSAGE);}
      tension_value = n;  
      tension_color = tension_color_calculation(tension_value);
      tooltip.text=name+"-"+str(tension_value);
    }
  }

  void delete() {
    // println("deleting tension " + name);
    deleted = true; 
    // delete the tension from all the units that are tensioned with it
    for (int j=0; j<i_cur_node; j++) {
      Unit u = (Unit) nodes[j];
      if (u.unit_tension_name.equals(name)) u.unit_tension_name = "NULL"; 
    } // END FOR EACH UNIT
    update_tension_lists(name, -1, "DEL");
  }
  
  void modify_name() {
    Tension aux_t;
    String name_aux = showInputDialog("Please enter new tension description", name);
    if (name_aux == null || "".equals(name_aux))
      showMessageDialog(null, "Empty TEXT Input!!!", "Alert", ERROR_MESSAGE);
    else {
      aux_t = search_tension(name_aux);
      if (aux_t!=null)
        {showMessageDialog(null, "Tension \"" + name_aux + "\" exists already!!!", "Alert", ERROR_MESSAGE);}
      else {
      showMessageDialog(null, "Tension \"" + name + "\" changed name into " + name_aux, "Info", INFORMATION_MESSAGE);
      for (int i=0; i<i_cur_node; i++) { // update tension name in all nodes containing it
        Unit u = (Unit) nodes[i];
        if (u.unit_tension_name.equals(name)) u.modify_tension_name(name_aux);
      }
      name=name_aux; tooltip.text=name+str(tension_value);
      // String old_id = id;
      int i = searchStringIndex(id, tension_ids, 0, i_cur_tension);
      // tensions_checkbox.addItem(name, i);
      tension_ids = deleteStringByIndex(i, tension_ids); i_cur_tension--; // temporarily, tensions are decreased
      id = create_tension_id(name); 
      tension_ids = insertStringAtIndex(id, i, tension_ids); i_cur_tension++;
      // replaceString(old_id, id, tension_ids, 0, i_cur_tension);
      }
    }
  }  
}
