// =================================================================================================
// LOGIC CONSTRAINTS: based upon preconditions and effects 

// LIBRARY FOR STATES
State[] states;
String[] state_names;
String[] state_ids; int state_id_suffix = 0; // Tag id's are printed in the tag box
int total_states;
int max_states_per_node;
int i_cur_state;
int i_select_state;

void states_settings() {
  total_states = 1000;
  max_states_per_node = total_states;
}

void states_setup() {
  i_cur_state = 0;
  i_select_state = -1;
  states = new State[total_states];
  state_ids = new String[total_states];
  state_names = new String[total_states];
  // state_names[0] = "fake_state_0"; state_names[1] = "fake_state_1"; i_cur_state=2;
  // for each unit, calculate painting and sculting edges
  for (int i=0; i<i_cur_node; i++) {
    Unit u = (Unit) nodes[i];
    u.update_constraints_edges_preconditions();
    u.update_constraints_edges_effects();
  }
}

// color of state buttons (45, 30, 100)
void states_color_setup() {
  colorMode(HSB, 360, 100, 100);
  if (i_cur_state>0) {
    // float color_interval = 45 / i_cur_state; float start = 50; //random(360);
    for (int i=0; i < i_cur_state; i++) {
      states[i].state_color = color(45, 30, 100);
    }
  }
}

// calculation of the state button position in the bottom offset
void states_position_setup() {
  if (i_cur_state>0) {
    float state_width = actual_width / i_cur_state; // computes box height
    if (state_width >= left_offset) {state_width=left_offset;} // not more than diameter_size
    for (int i=0; i < i_cur_state; i++) {
      states[i].w = state_width; states[i].h = bottom_offset;  // rectangle
      states[i].x = (left_offset + i*(state_width + margin) + states[i].w/2)/zoom-xo; 
      states[i].y = (size_y - states[i].h/2)/zoom-yo;
      states[i].tooltip.x = states[i].x; states[i].tooltip.y = states[i].y;
    }
  }
}

void update_states(String state_name, String mode) {
  // println("update_states: " + state_name + ", of " + i_cur_state + " states");
  switch (mode) {
    case("ADD"):
      if (searchStateIndex(state_name)==-1) {
        // println("i_cur_preconditions_checkbox: " + i_cur_preconditions_checkbox);
        state_names[i_cur_state] = state_name;
        states[i_cur_state] = new State(state_name);
        //preconditions_checkbox.addItem("PRE:" + states[i_cur_state].id, i_cur_preconditions_checkbox); 
        //preconditions_checkbox.getItem(i_cur_preconditions_checkbox).getCaptionLabel().alignX(RIGHT)._myPaddingX=preconditions_checkbox.getItem(i_cur_preconditions_checkbox).getWidth();
        //i_cur_preconditions_checkbox++;
        //effects_checkbox.addItem("EFF:" + states[i_cur_state].id, i_cur_effects_checkbox); i_cur_effects_checkbox++;
        i_cur_state++;
      }
      break;
    case("DEL"): // removing a state button and state labeling of a node (it should remove from checkbox)
      int index = searchStateIndex(state_name); // store the index of the state to delete
      if (index!=-1) { // if not null
        // REMOVING FROM CHECKBOX DOES NOT WORK!
        //preconditions_checkbox.removeItem("PRE:" + states[index].id);
        //effects_checkbox.removeItem("EFF:" + states[index].id);
        // delete the state from all the units that have it in preconditions or effects 
        for (int j=0; j<i_cur_node; j++) { // FOR EACH UNIT
          Unit u = (Unit) nodes[j];
          u.delete_unit_precondition("PRE:"+states[index].id);
          // print4check("After: Unit " + u.id + "(" + u.unit_preconditions_counter + " states)", 0, u.unit_preconditions_counter, u.unit_preconditions);
          u.delete_unit_effect("EFF:"+states[index].id);
          // print4check("After: Unit " + u.id + "(" + u.unit_effects_counter + " states)", 0, u.unit_effects_counter, u.unit_effects);
        } // END FOR EACH UNIT
        // delete state and copy back all the 
        states[index].delete();
        // auxiliary state list and auxiliary state id list (with one less)
        State[] states_aux = new State[i_cur_state-1]; String[] state_ids_aux = new String[i_cur_state-1];
        for (int i=0; i<index; i++) {states_aux[i]=states[i]; state_ids_aux[i]=state_ids[i];}
        for (int i=index; i<i_cur_state-1; i++) {states_aux[i]=states[i+1]; state_ids_aux[i]=state_ids[i+1];}
        for (int i=0; i<states_aux.length; i++) {states[i]=states_aux[i]; state_ids[i]=state_ids_aux[i];}
        i_cur_state--;
      }
      break;
  } // END SWITCH
  states_color_setup(); 
  states_position_setup();
  // println("update_states: " + i_cur_state + " states");
}

// identify mouse click for a state
int state_click() {
  int i_select_aux=-1;
  float x = mouseX; float y = mouseY; // capture mouse position
  for (int i=0; i<i_cur_state; i++) { // for each state 
    if (x < (states[i].x+states[i].w/2)*zoom+xo && x > (states[i].x-states[i].w/2)*zoom+xo && // if the mouse is over the state box
        y < (states[i].y+states[i].h/2)*zoom+yo && y > (states[i].y-states[i].h/2)*zoom+yo) {
        i_select_aux=i; 
    }
  } // END FOR
  return i_select_aux;
}

// mouse selection for a state
void state_selection() {
  int i_select_aux = state_click(); // choose a state
  if (i_select_aux!=-1) { // if successful
    if (selection_possible) { // if nothing was selected before
      i_select_state = i_select_aux; select_type = "STATE";  selection_possible=false;
    } else 
    if (select_type.equals("STATE")) { // if previous selection is a state
      if (i_select_state==i_select_aux) { // if same state, deselect
        i_select_state = -1; select_type = "NULL";  selection_possible=true;
      }
    } else
    if (select_type.equals("NODE")) { // if previous selection is a node, allow state selection
      i_select_state = i_select_aux; select_type = "NODE+STATE";  selection_possible=false;
    }
  } // END STATE WAS SELECTED
}

// draw state buttons
void draw_states() {
  // STATEs header
  //fill(text_color);
  //flex_write_lines_in_box("STATEs", default_font_name, default_font_aspect_ratio, 
  //                        "CENTER", "CENTER", 
  //                        (left_offset/2)/zoom-xo, (size_y-(bottom_offset)/2)/zoom-yo, left_offset, bottom_offset);  
  for (int i=0; i < i_cur_state; i++) {
    // println("color of state " + i);
    if ((select_type=="STATE" || select_type=="NODE+STATE") && i==i_select_state) {fill(select_color);} 
    else {fill(states[i].state_color);} 
    if (!states[i].deleted) {
      rectMode(CENTER);
      rect(states[i].x,states[i].y,states[i].w,states[i].h);
      if ((select_type=="STATE" || select_type=="NODE+STATE") && i==i_select_state) {fill(select_text_color);} 
      else {fill(text_color);}
      flex_write_lines_in_box(states[i].id, default_font_name, default_font_aspect_ratio, 
                              "CENTER", "CENTER", 
                              states[i].x, states[i].y, states[i].w, states[i].h);
    }
  }
}

// search functions on states
State searchState(String state_name) {
  for (int i=0; i<i_cur_state; i++) {
    if (states[i].name.equals(state_name)) {return states[i];} 
  }
  return null;
}

State searchStateById(String state_id) {
  for (int i=0; i<i_cur_state; i++) {
    if (states[i].id.equals(state_id)) {return states[i];} 
  }
  return null;
}

int searchStateIndex(String state_name) {
  for (int i=0; i<i_cur_state; i++) {
    if (states[i].name.equals(state_name)) {return i;} 
  }
  return -1;
}

void initialize_state_list(String[] state_list) {
  for (int i=0; i<state_list.length; i++) {
    state_list[i]="NULL STATE";
  }
}

String create_state() {
  String state_aux = showInputDialog("Please enter new state");
  if (state_aux == null || "".equals(state_aux))
    showMessageDialog(null, "Empty state!!!", "Alert", ERROR_MESSAGE);
  else if (searchStateIndex(state_aux)!=-1)
    showMessageDialog(null, "ID \"" + state_aux + "\" exists already!!!", "Alert", ERROR_MESSAGE);
  else {
    showMessageDialog(null, "ID \"" + state_aux + "\" successfully added!!!", "Info", INFORMATION_MESSAGE);
    //update_states(state_aux, "ADD");
  }
  return state_aux;
}
  
// create new identifier for state label on button
String create_state_id(String new_name) { // creates id's (3 letters) for states
  boolean id_ok = false; String id_aux = "NULL"; 
  String suffix = str(state_id_suffix); if (suffix.length()==1) {suffix = "0"+suffix;}
  int index1=0, index2=1, index3=2;
  while (!id_ok) {
    // proposal
    if (new_name.length()>=3) {id_aux = str(new_name.charAt(index1)) + str(new_name.charAt(index2)) + str(new_name.charAt(index3++));}
    else if (new_name.length()>=2) {id_aux = str(new_name.charAt(index1)) + str(new_name.charAt(index2++)) + str(0);}
    else if (new_name.length()>=1) {id_aux = str(new_name.charAt(index1)) + str(0) + str(0);}
    // disposal
    if (searchStringIndex(id_aux, state_ids, 0, i_cur_state)==-1) {
      id_ok=true;
    }
  }
  println("NEW STATE ID = " + id_aux);
  return id_aux;
}  

// state name layover through tooltip
void state_layover() {
  // search for the tooltip to display
  float x = mouseX; float y = mouseY; // capture mouse position
  for (int i=0; i<i_cur_state; i++) { // for each state 
    ToolTip tt = states[i].tooltip; 
    if (x < (states[i].x+states[i].w/2)*zoom+xo && x > (states[i].x-states[i].w/2)*zoom+xo) { // if the mouse is over such state box
      if (y < (states[i].y+states[i].h/2)*zoom+yo && y > (states[i].y-states[i].h/2)*zoom+yo) {
        // tt.x= x/zoom-xo; tt.y= y/zoom-yo; 
        tt.x= x/zoom-xo; tt.y= y/zoom-yo; 
        color c = color(0, 0, 80, 10); // color(0, 80, 255, 30);
        tt.setBackground(c); // color(0,80,255,30));
        tt.display();
      }
    }
  } // END FOR
} 


// STATE CLASS DEFINITION

class State {
  String name;
  String id;
  float x,y;
  float w,h;
  float x_min, x_max, y_min, y_max;
  color state_color;
  boolean deleted;
  ToolTip tooltip;
  
  State (String _name) {
    name = _name; x=-1; y=-1; w=left_offset; h=diameter_size; deleted = false;
    tooltip = new ToolTip(name, x, y-w, size_x/2, size_y/2, default_font_name, default_font_size, default_font_aspect_ratio);
    id = create_state_id(name); state_ids[i_cur_state]=id;
  }

  void delete() {
    // println("deleting state " + name);
    deleted = true; 
  }

  void modify_name() {
    State aux_a;
    String name_aux = showInputDialog("Please enter new state", name);
    if (name_aux == null || "".equals(name_aux))
      showMessageDialog(null, "Empty TEXT Input!!!", "Alert", ERROR_MESSAGE);
    else {
      aux_a = searchState(name_aux);
      if (aux_a!=null)
        {showMessageDialog(null, "STATE \"" + name_aux + "\" exists already!!!", "Alert", ERROR_MESSAGE);}
      else {
      showMessageDialog(null, "STATE \"" + name + "\" changed name into " + name_aux, "Info", INFORMATION_MESSAGE);
      for (int i=0; i<i_cur_node; i++) { // update state name in all units containing it
        Unit u = (Unit) nodes[i];
        u.replace_unit_precondition_name(name,name_aux);
        u.replace_unit_effect_name(name,name_aux);
      }
      replaceString(name, name_aux, state_names, 0, i_cur_state);
      name=name_aux; tooltip.text=name;
      int i = searchStringIndex(id, state_ids, 0, i_cur_state);
      // preconditions_checkbox.addItem(name, i);
      // effects_checkbox.addItem(name, i);
      // state_ids = deleteStringByIndex(i, state_ids); i_cur_state--; 
      String old_id = id;
      id = create_state_id(name); 
      replaceString(old_id, id, state_ids, 0, i_cur_state);
      // state_ids = insertStringAtIndex(id, i, state_ids); i_cur_state++;
      }
    }
  }  

} // END CLASS STATE

// LIBRARY PRE-EFFs

void constraints_layout_bg() {
  color(HSB, 360,100,100);
  fill(0,0,95); // fill(45,30,100);
  rect((left_offset+actual_width/2)/zoom-xo, (top_offset+actual_height/2)/zoom-yo, actual_width, actual_height);
  // image(tension_bg, (left_offset+actual_width/2)/zoom-xo, (top_offset+actual_height/2)/zoom-yo, actual_width, actual_height);
}
