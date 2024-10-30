// STORY UNITS: GLOBAL VARIABLES
int max_agents_per_unit;

void unit_settings() {
  max_agents_per_unit = 1000;
}


class Unit extends Node {
  String[] unit_agents; int unit_agents_counter;
  int unit_propp_tag_index; // one of {"Int", "Vio", "Cv", "L", "D", "E", "F", "G", "H", "I", "K", "Rew"}
  String[] unit_preconditions; int unit_preconditions_counter;
  String[] unit_effects; int unit_effects_counter;
  String unit_tension_name; // name of the tension
  
  Unit(float x_aux, float y_aux, float w_aux, float h_aux, String id_aux, String text_aux, String tag_aux) {
    // Node(float x_aux, float y_aux, float w_aux, float h_aux, String id_aux, String text_aux, String tag_aux)
    super(x_aux, y_aux, w_aux, h_aux, id_aux, text_aux, tag_aux);
    unit_agents = new String[max_agents_per_unit]; unit_agents_counter=0;
    unit_propp_tag_index = -1; unit_tension_name = "NULL"; unit_tension_name = "NULL";
    unit_preconditions = new String[total_states]; unit_preconditions_counter=0;
    unit_effects = new String[total_states]; unit_effects_counter=0;
    if (white_page) {white_page=false;}
  }

  //void show_states() {
  //  if (unique_event) {
  //    unique_event=false;
  //    println("showing preconditions:"); for (int j=0; j<unit_preconditions_counter; j++) {print(" " + unit_preconditions[j]);}
  //    int number_of_items = preconditions_checkbox.getItems().size();
  //    // println("number_of_items:" + number_of_items);
  //    // PRECONDITIONS
  //    for (int j=0; j<number_of_items; j++) {preconditions_checkbox.getItem(j).setState(false);} // all items initialized to false
  //    for (int i=0; i<unit_preconditions_counter; i++) { // for each precondition state of this node
  //      for (int j=0; j<number_of_items; j++) { // for each item of preconditions checkbox
  //        if (preconditions_checkbox.getItem(j).getName().substring(4).equals(unit_preconditions[i])) { // if the two names coincide (excluding "PRE:")
  //          preconditions_checkbox.getItem(j).setState(true);} // set item state to true 
  //      } // END for each precondition checkbox
  //    } // END for each precondition 
  //    preconditions_checkbox.setPosition((x-w/2-preconditions_checkbox.getWidth())*zoom+xo,y*zoom+yo).show();
  //    // EFFECTS
  //    for (int j=0; j<number_of_items; j++) {effects_checkbox.getItem(j).setState(false);} // all items initialized to false
  //    for (int i=0; i<unit_effects_counter; i++) { // for each effect state of this node
  //      for (int j=0; j<number_of_items; j++) { // for each item of effects checkbox
  //        if (effects_checkbox.getItem(j).getName().substring(4).equals(unit_effects[i])) { // if the two names coincide (excluding "EFF:")
  //          effects_checkbox.getItem(j).setState(true);} // set item state to true 
  //      } // END for each effect checkbox
  //    } // END for each effect
  //    effects_checkbox.setPosition((x+w/2)*zoom+xo,y*zoom+yo).show();
  //    unique_event=true;
  //  }
  //} // END SHOW STATES

  void show_preconditions_and_effects() { // display the preconditions and the effects over the unit
    float bx = x; float by = y; // center coordinates of effects box rectangle initially set to unit center
    String effects_box_text = "EFFECTS: "; 
    if (unit_effects_counter==0) {effects_box_text = effects_box_text + "NULL";}
    else for (int i=0; i<unit_effects_counter; i++) {effects_box_text = effects_box_text + unit_effects[i] + " - ";}
    String[] words = split_text_into_words (effects_box_text);
    float[] box_size = determine_box_size(words, default_font_aspect_ratio, default_font_size);
    float effects_box_width = box_size[0]; 
    float effects_box_height = box_size[1]; 
    bx = check_horizontal_boundaries(x+w/2+effects_box_width/2, effects_box_width); // display at the right
    by = check_vertical_boundaries(y+effects_box_height/2, effects_box_height); //  display below
    String preconditions_box_text = "PRECONDITIONS: "; 
    if (unit_preconditions_counter==0) {preconditions_box_text = preconditions_box_text + "NULL";}
    else for (int i=0; i<unit_preconditions_counter; i++) {preconditions_box_text = preconditions_box_text + unit_preconditions[i] + " - ";}
    words = split_text_into_words (preconditions_box_text);
    box_size = determine_box_size(words, default_font_aspect_ratio, default_font_size);
    float preconditions_box_width = box_size[0];  
    float preconditions_box_height = box_size[1]; 
    float pre_bx = check_horizontal_boundaries(bx-effects_box_width/2-preconditions_box_width/2, preconditions_box_width); // display at the left of the effects
    float pre_by = check_vertical_boundaries(y+preconditions_box_height/2, preconditions_box_height); //  display below
    fill(0, 0, 100); //tbackground); WHITE background
    noStroke(); rectMode(CENTER);  
    rect(bx, by, effects_box_width, effects_box_height); 
    write_lines_in_fixed_fontsize(effects_box_text, default_font_name, default_font_aspect_ratio, default_font_size, "LEFT", "TOP", bx, by);
    fill(0, 0, 100); //tbackground); WHITE background
    noStroke(); rectMode(CENTER);  
    rect(pre_bx, pre_by, preconditions_box_width, preconditions_box_height); 
    write_lines_in_fixed_fontsize(preconditions_box_text, default_font_name, default_font_aspect_ratio, default_font_size, "LEFT", "TOP", pre_bx, pre_by);
  } // END METHOD show_proconditions_and_effects
  
  // add a precondition name to a unit
  void add_unit_precondition(String state_name) {
    int i = searchStringIndex(state_name, state_names, 0, i_cur_state);
    int j = searchStringIndex(states[i].name, unit_preconditions, 0, unit_preconditions_counter);
    if (i!=-1 && j==-1) {
      unit_preconditions[unit_preconditions_counter]=states[i].name;
      unit_preconditions_counter++;
      update_constraints_edges_preconditions();
    }
  }

  // add an effect to a unit
  void add_unit_effect(String state_name) {
    int i = searchStringIndex(state_name, state_names, 0, i_cur_state);
    int j = searchStringIndex(states[i].id, unit_effects, 0, unit_effects_counter);
    if (i!=-1 && j==-1) {
      unit_effects[unit_effects_counter]=states[i].name;
      unit_effects_counter++;
      update_constraints_edges_effects();
    }
  }

  // replace a precondition in a unit
  void replace_unit_precondition_name(String old_name, String new_name) {
    for (int j=0; j<unit_preconditions_counter; j++)
      if (unit_preconditions[j].equals(old_name)) {
        unit_preconditions[j]=new_name; 
    }
  }

  // replace a effect in a unit
  void replace_unit_effect_name(String old_name, String new_name) {
    for (int j=0; j<unit_effects_counter; j++)
      if (unit_effects[j].equals(old_name)) {
        unit_effects[j]=new_name; 
    }
  }

  // delete a precondition from a unit
  void delete_unit_precondition(String state_name) {
    int index = -1;
    for (int i=0; i<unit_preconditions_counter; i++) {
      if (unit_preconditions[i].equals(state_name)) {index = i;}
    }
    if (index!=-1) {
      for (int i=0; i<index; i++) {unit_preconditions[i]=unit_preconditions[i];}    
      for (int i=index; i<unit_preconditions_counter; i++) {unit_preconditions[i]=unit_preconditions[i+1];} 
      unit_preconditions_counter--;
      update_constraints_edges_preconditions();
    }
  }

  // delete an effect from a unit
  void delete_unit_effect(String state_name) {
    int index = -1;
    for (int i=0; i<unit_effects_counter; i++) {
      if (unit_effects[i].equals(state_name)) {index = i;}
    }
    if (index!=-1) {
      for (int i=0; i<index; i++) {unit_effects[i]=unit_effects[i];}    
      for (int i=index; i<unit_effects_counter; i++) {unit_effects[i]=unit_effects[i+1];} 
      unit_effects_counter--;
      update_constraints_edges_effects();
    }
  }

  //void modify_preconditions_from_checkbox() { 
  //  println("modifying preconditions: \n"); for (int i=0; i<unit_preconditions_counter; i++) {print(" " + unit_preconditions[i] + "\n");}
  //  unit_preconditions_counter = 0; // int i=0;
  //  for (int i=0; i<cur_unit_preconditions_from_checkbox.length; i++) {
  //  // while (!cur_unit_preconditions_from_checkbox[i].equals("NULL STATE") && i<cur_unit_preconditions_from_checkbox.length) {
  //    if (!cur_unit_preconditions_from_checkbox[i].equals("NULL STATE")) {
  //    // println("modify_preconditions_from_checkbox: unit_preconditions_from_checkbox " + i + "= " + cur_unit_preconditions_from_checkbox[i]); 
  //      unit_preconditions[unit_preconditions_counter] = cur_unit_preconditions_from_checkbox[i].substring(4);
  //      unit_preconditions_counter++; // i++;
  //    }
  //  }
  //  // hide_all_menus();
  //  update_constraints_edges_preconditions();
  //  // initialize_state_list(cur_unit_preconditions_from_checkbox); // reset the temporary list of preconditions
  //  // print("\n modified preconditions:"); for (int j=0; j<unit_preconditions_counter; j++) {print(" " + unit_preconditions[j]);}
  //}

  //void modify_effects_from_checkbox() { 
  //  println("modifying effects:"); for (int i=0; i<unit_effects_counter; i++) {print(" " + unit_effects[i]);}
  //  unit_effects_counter = 0; // int i=0;
  //  for (int i=0; i<cur_unit_effects_from_checkbox.length; i++) {
  //  // while (!cur_unit_effects_from_checkbox[i].equals("NULL STATE") && i<cur_unit_effects_from_checkbox.length) {
  //    if (!cur_unit_effects_from_checkbox[i].equals("NULL STATE")) {
  //    // println("modify_effects: unit_effects_from_checkbox " + i + "= " + cur_unit_effects_from_checkbox[i]); 
  //      unit_effects[unit_effects_counter] = cur_unit_effects_from_checkbox[i].substring(4);
  //      unit_effects_counter++; // i++;
  //    }
  //  }
  //  // hide_all_menus(); 
  //  update_constraints_edges_effects();
  //  // initialize_state_list(cur_unit_effects_from_checkbox); // reset the temporary list of effects
  //  // println("modified effects:"); for (int j=0; j<unit_effects_counter; j++) {print(" " + unit_effects[j]);}
  //}

  // *** NEXT TWO ARE UPDATES FOR PRECONDITIONS/EFFECTS CONSTRAINTS UNDER
  // *** *** MODALITY ADDITION (PAINTING): NO PRECONDITIONS -> NO UNIT CAN PRECEDE
  // *** *** MODALITY SUBTRACTION (SCULPTING): NO PRECONDITIONS -> ALL UNITS CAN PRECEDE
  void update_constraints_edges_preconditions() { // update edges that get at this node (head)
    // println("update_constraints_edges_preconditions() for " + i_cur_node + " nodes and " + i_cur_edge + " edges");
    for (int i=0; i<i_cur_node; i++) { // for each other unit
      Unit ui = (Unit) nodes[i];  
      // *** TEST IF unit ui EFFECTS SATISFY ALL PRECONDITIONS of this unit
      int p=0; String state_name = "NULL"; boolean ui_satisfies = true; // ui satisfies this unit preconditions, when no precondition has been examined yet (p=0)
      while (p<unit_preconditions_counter && ui_satisfies) { // ; p++) { // for each precondition of this unit
        boolean found = false; // found one effect in ui that satisfies precondition number p
        for (int f=0; f<ui.unit_effects_counter; f++) { // find an effect in ui that satisfies this precondition
          if (ui.unit_effects[f].equals(unit_preconditions[p])) {
            found=true; State s = searchState(unit_preconditions[p]); state_name=s.name;
          } 
        }
        if (!found) {ui_satisfies=false;} // if not found, ui does not satisfy this unit preconditions
        p++;
      } // END WHILE - for each precondition of this unit
      if (plot_generation_mode.equals("PAINTING")) { // if PAINTING submode
        // *** ADD EDGE ... 
        if (unit_preconditions_counter>0 && ui_satisfies) { // if all preconditions (>0) are satisfied by ui effects
          if (search_edge_head_tail_index(searchNodeIdIndex(id), i, "PAINTING")==-1) { // if edge does not exist in PAINTING MODE
            int index = search_edge_head_tail_index(searchNodeIdIndex(id), i, "NULL");
            // *** ... BY CREATION OF A NEW EDGE (IN PAINTING MODE)
            if (index==-1) { // if edge does not exist at all, create edge
              create_edge(id, ui.id, state_name);
              // edges[i_cur_edge]=new Edge(id, ui.id, "e"+str(i_cur_edge), state_name, "PAINTING"); 
              // i_cur_edge++; 
            } else { // if edge exists, add PAINTING to pg_modes
            // *** ... BY ONLY ADDING PAINTING MODE TO EXISTING EDGE 
              int m=0; boolean added = false; 
              while (!added && m<edges[index].pg_modes.length) { // loop over edge modes to add PAINTING
                if (edges[index].pg_modes[m].equals("NULL")) {
                  edges[index].pg_modes[m]="PAINTING"; added=true; edges[index].pg_mode_counter++;} 
                else {m++;}           
              } // END WHILE edge modes
            } // END ELSE (edge exists)
          } // END IF (this edge does not exist in PAINTING mode)
        } else // *** NON SATISFACTION OR NO PRECONDITIONS: DELETE PAINTING MODE OR DELETE EDGE FROM UI           
        if ((!ui_satisfies || unit_preconditions_counter==0) && // if not all preconditions (>0) are satisfied by ui effects or 0 preconditions
             search_edge_head_tail_index(searchNodeIdIndex(id), i, "PAINTING")!=-1) { // and the edge exists
          int index = search_edge_head_tail_index(searchNodeIdIndex(id), i, "PAINTING");
          // DELETE PAINTING MODE FROM EDGE MODES
          replaceString("PAINTING", "NULL", edges[index].pg_modes, 0, edges[index].pg_modes.length); edges[index].pg_mode_counter--;
          // if pg_modes are all NULL, delete the edge
          if (allNullStrings(edges[index].pg_modes)) {
            edges[index].delete(); // delete the edge
          }
        } // END IF NO SATISFACTION OR 0 PRECONDITIONS
      } // else // END IF PAINTING MODE
      // ======================== SCULPTING MODE ========================
    //  if (plot_generation_mode.equals("SCULPTING")) { // if SCULPTING mode
    //    // *** ADD EDGE ... 
    //    if (unit_preconditions_counter==0 || ui_satisfies) { // if all preconditions are satisfied by ui effects, possibly because 0 preconditions
    //      if (search_edge_head_tail_index(searchNodeIdIndex(id), i, "SCULPTING")==-1) { // if edge does not exist in SCULPTING MODE
    //        int index = search_edge_head_tail_index(searchNodeIdIndex(id), i, "NULL");
    //        // *** ... CREATION OF A NEW EDGE (IN PAINTING MODE)
    //        if (index==-1) { // if edge does not exist at all, create edge
             // create_edge(id, ui.id, state_name);
    //          edges[i_cur_edge]=new Edge(id, ui.id, "e"+str(i_cur_edge), state_name, "PAINTING"); 
    //          i_cur_edge++; 
    //        } else { // if edge exists, add PAINTING to pg_modes
    //        // *** ... ADD PAINTING MODE TO EXISTING EDGE 
    //          int m=0; boolean added = false; 
    //          while (!added && m<edges[index].pg_modes.length) { // loop over edge modes to add PAINTING
    //            if (edges[index].pg_modes[m].equals("NULL")) {
    //              edges[index].pg_modes[m]="PAINTING"; added=true; edges[index].pg_mode_counter++;} 
    //            else {m++;}           
    //          }
    //        }
    //      }
    //    } else // *** NON SATISFACTION OR NO PRECONDITIONS: DELETE INCOMING EDGES FROM UI           
    //    if ((!ui_satisfies || unit_preconditions_counter==0) && // if not all preconditions (>0) are satisfied by ui effects or 0 preconditions
    //         search_edge_head_tail_index(searchNodeIdIndex(id), i, "PAINTING")!=-1) { // and the edge exists
    //      int index = search_edge_head_tail_index(searchNodeIdIndex(id), i, "PAINTING");
    //      replaceString("PAINTING", "NULL", edges[index].pg_modes, 0, edges[index].pg_modes.length); edges[index].pg_mode_counter--;
    //      // if pg_modes are all NULL, delete the edge
    //      if (allNullStrings(edges[index].pg_modes)) {
    //        edges[index].delete(); // delete the edge
    //      }
    //    } // END IF  
    //  } // END FOR EACH OTHER UNIT 
    //} // IF PAINTING MODE        
        
        //if (plot_generation_submode.equals("SCULPTING") && unit_preconditions_counter==0) {satisfied=true;}
        //else if (plot_generation_submode.equals("PAINTING") && unit_preconditions_counter==0) {satisfied=false;}
        //if (satisfied && search_edge_head_tail_index(searchNodeIdIndex(id), i)==-1) { // if all preconditions matched and edge does not exist, create edge
        //  // println("unit "+i+".unit_effects["+is+"] = " + ui.unit_effects[is]); println("unit "+j+".unit_preconditions["+js+"] = " + uj.unit_preconditions[js]); 
        //  create_edge(id, ui.id, "NULL");
        //  edges[i_cur_edge]=new Edge(id, ui.id, "e"+str(i_cur_edge), "NULL", plot_generation_mode); 
        //  i_cur_edge++;
        //} else 
        //if (!satisfied && search_edge_head_tail_index(searchNodeIdIndex(id), i)!=-1) {           
        //  edges[search_edge_head_tail_index(searchNodeIdIndex(id), i)].delete(); 
        //} 
      // } // END FOR EACH OTHER UNIT
    // } // END IF
    } // END FOR EACH UNIT
  }

  void update_constraints_edges_effects() { // update edges that depart from this node (tail)
    // println("update_constraints_edges() for " + i_cur_node + " nodes and " + i_cur_edge + " edges");
    // if (plot_generation_mode == "PRE-EFFs") {
      if (plot_generation_mode.equals("PAINTING")) { // if PAINTING submode
        // add or delete painting edges to account for the current situation
        for (int i=0; i<i_cur_node; i++) { // for each other unit
          Unit ui = (Unit) nodes[i];  
          // *** if this unit satifies all the preconditions of ui, build a painting edge from u to ui (if not already existent)
          int p=0; boolean ui_satisfied = true; String state_name = "NULL"; // ui satisfied by this unit preconditions, when no precondition has been examined yet (p=0)
          while (p<ui.unit_preconditions_counter && ui_satisfied) { // for each precondition of unit ui
            boolean found = false; // found one effect in this unit that satisfies precondition number p (NOT YET = FALSE)
            for (int f=0; f<unit_effects_counter; f++) { // find an effect in this unit that satisfies current precondition of u
              if (unit_effects[f].equals(ui.unit_preconditions[p])) {
                found=true; State s = searchState(ui.unit_preconditions[p]); state_name=s.name;
              } 
            }
            if (!found) {ui_satisfied=false;} // if not found, this unit effects do not satisfy ui preconditions
            p++;
          } // END WHILE
          // *** ADD EDGE ... 
          if (ui.unit_preconditions_counter>0 && ui_satisfied) { // if all preconditions (>0) of ui are satisfied by this unit effects
            if (search_edge_head_tail_index(i, searchNodeIdIndex(id), "PAINTING")==-1) { // if edge does not exist in PAINTING MODE
              int index = search_edge_head_tail_index(searchNodeIdIndex(ui.id), i, "NULL");
              // *** ... BY CREATION 
              if (index==-1) { // if edge does not exist at all, create edge
                create_edge(ui.id, id, state_name);
                // edges[i_cur_edge]=new Edge(ui.id, id, "e"+str(i_cur_edge), state_name, "PAINTING"); 
                // i_cur_edge++;
              } else { // if edge exists, add PAINTING to pg_modes
              // *** ... BY ADDING MODE TO EXISTING EDGE
                int m=0; boolean added = false; 
                while (!added && m<edges[index].pg_modes.length) {
                  if (edges[index].pg_modes[m].equals("NULL")) {
                    edges[index].pg_modes[m]="PAINTING"; added=true; edges[index].pg_mode_counter++;} 
                  else {m++;}           
                }
              } // END ADD PAINTING TO MODES
            }
          } else 
          // *** NON SATISFACTION OR NO PRECONDITIONS: DELETE INCOMING EDGES FROM UI 
          if ((!ui_satisfied || ui.unit_preconditions_counter==0) && // if not all preconditions (>0) are satisfied by this unit effects or 0 preconditions
               search_edge_head_tail_index(i, searchNodeIdIndex(id), "PAINTING")!=-1) { // and the edge exists
            int index = search_edge_head_tail_index(i, searchNodeIdIndex(id), "PAINTING"); // find the edge index
            replaceString("PAINTING", "NULL", edges[index].pg_modes, 0, edges[index].pg_modes.length); edges[index].pg_mode_counter--;
            // if pg_modes are all NULL, delete the edge
            if (allNullStrings(edges[index].pg_modes)) {
              edges[index].delete(); // delete the edge
              // WHAT ELSE TO DO???
            }
          } 
        } // END FOR EACH OTHER UNIT 
      } // IF PAINTING MODE        
    //if (plot_generation_mode.equals("SCULPTING") && ui.unit_preconditions_counter==0) {satisfied=true;}
        //else if (plot_generation_mode.equals("PAINTING") && ui.unit_preconditions_counter==0) {satisfied=false;}
        //if (satisfied && search_edge_head_tail_index(i, searchNodeIdIndex(id))==-1) {           
        //  // println("unit "+i+".unit_effects["+is+"] = " + ui.unit_effects[is]); println("unit "+j+".unit_preconditions["+js+"] = " + uj.unit_preconditions[js]); 
        //  edges[i_cur_edge]=new Edge(ui.id, id, "e"+str(i_cur_edge), "NULL", plot_generation_mode); 
        //  i_cur_edge++; 
        //} else
        //if (!satisfied && search_edge_head_tail_index(i, searchNodeIdIndex(id))!=-1) {           
        //  // println("unit "+i+".unit_effects["+is+"] = " + ui.unit_effects[is]); println("unit "+j+".unit_preconditions["+js+"] = " + uj.unit_preconditions[js]); 
        //  edges[search_edge_head_tail_index(i, searchNodeIdIndex(id))].delete(); 
        //}
     // } // END FOR EACH OTHER UNIT
    // } // END IF
  }

  //void show_propp_tag() {
  //  if (plot_generation_mode == "PROPP") {
  //  // println("showing propp tag:"); 
  //  int number_of_items = propp_checkbox.getItems().size();
  //  if (unique_event) {
  //    unique_event=false;
  //    for (int j=0; j<number_of_items; j++) {propp_checkbox.getItem(j).setState(false);} // all items initialized to false
  //    if (unit_propp_tag_index!=-1) {propp_checkbox.getItem(unit_propp_tag_index).setState(true);}
  //    // float bx = check_horizontal_boundaries(x-w/2-(propp_checkbox.getWidth()), propp_checkbox.getWidth());
  //    float bx = check_horizontal_boundaries(x-w/2-propp_checkbox.getWidth(), max_length_propp_id*default_font_width);
  //    //float by = check_vertical_boundaries(y, propp_checkbox.getHeight());
  //    float by = check_vertical_boundaries(y, number_of_items*(default_font_size+spacing_row));
  //    propp_checkbox.setPosition(bx*zoom+xo,by*zoom+yo).show();
  //  }
  //  unique_event = true;
  //  }
  //}
  
  void show_propp_tag() { // display the Propp tag assigned to the unit
    float bx = x; float by = y; // center coordinates of propp tag box rectangle initially set to unit center
    String propp_tag_box_text = "PROPP_TAG NULL"; if (unit_propp_tag_index!=-1) {propp_tag_box_text = "PROPP TAG "+proppTags[unit_propp_tag_index];}
    String[] words = split_text_into_words (propp_tag_box_text);
    float[] box_size = determine_box_size(words, default_font_aspect_ratio, default_font_size);
    float box_width = box_size[0]; // id_general_length*default_font_width; 
    float box_height = box_size[1]; // 2*default_font_size; // 2 lines TAG \n tag_id
    bx = check_horizontal_boundaries(x+w/2+box_width/2, box_width); // display at the right
    by = check_vertical_boundaries(y+box_height/2, box_height); //  display below
    fill(0, 0, 100); //tbackground); WHITE background
    noStroke(); rectMode(CENTER);  
    rect(bx, by, box_width, box_height); 
    write_lines_in_fixed_fontsize(propp_tag_box_text, default_font_name, default_font_aspect_ratio, default_font_size, "LEFT", "TOP", bx, by);
  } // END METHOD show_propp_tag
  
  
  void modify_propp_tag() {
    unit_propp_tag_index=cur_unit_propp_tag_index;
    if (unit_propp_tag_index!=-1) {x = propp_layout_x[unit_propp_tag_index]/zoom - xo;}
    else {x = (left_offset+diameter_size)/zoom - xo;}
    // hide_all_menus();     
  }

  // unit DRAWING
  void draw_unit() {    
    // println("Drawing unit " + id); // PRINT CHECK:
    if (!deleted) {
      draw_unit_agents();
      draw_node();
    }
  } // END draw_node

  void draw_unit_in_nav(String cur_pre_sub) {
    // PRINT CHECK: println("Drawing unit " + id);
    if (!deleted) {
      draw_node_in_nav(cur_pre_sub);
    }
  } // END draw_node

  void show_agents_and_tag() { // display the agents and the tag over the unit
    // show_tag();
    float bx = x; float by = y; // center coordinates of tag box rectangle initially set to unit center
    String tag_box_text = "TAG "+node_tag; //node_tags[0];
    String[] words = split_text_into_words (tag_box_text);
    float[] box_size = determine_box_size(words, default_font_aspect_ratio, default_font_size);
    float tag_box_width = box_size[0]; // id_general_length*default_font_width; 
    float tag_box_height = box_size[1]; // 2*default_font_size; // 2 lines TAG \n tag_id
    bx = check_horizontal_boundaries(x+w/2+tag_box_width/2, tag_box_width); // display at the right
    by = check_vertical_boundaries(y+tag_box_height/2, tag_box_height); //  display below
    String agents_box_text = "AGENTS "; for (int i=0; i<unit_agents_counter; i++) {agents_box_text = agents_box_text + unit_agents[i] + " ";}
    words = split_text_into_words (agents_box_text);
    box_size = determine_box_size(words, default_font_aspect_ratio, default_font_size);
    float agents_box_width = box_size[0]; // id_general_length*default_font_width; 
    float agents_box_height = box_size[1]; // 2*default_font_size; // 2 lines TAG \n tag_id
    float agt_bx = check_horizontal_boundaries(bx-tag_box_width/2-agents_box_width/2, agents_box_width); // display at the left of the tag
    float agt_by = check_vertical_boundaries(y+agents_box_height/2, agents_box_height); //  display below
    fill(0, 0, 100); //tbackground); WHITE background
    noStroke(); rectMode(CENTER);  
    rect(bx, by, tag_box_width, tag_box_height); 
    write_lines_in_fixed_fontsize(tag_box_text, default_font_name, default_font_aspect_ratio, default_font_size, "LEFT", "TOP", bx, by);
    fill(0, 0, 100); //tbackground); WHITE background
    noStroke(); rectMode(CENTER);  
    rect(agt_bx, agt_by, agents_box_width, agents_box_height); 
    write_lines_in_fixed_fontsize(agents_box_text, default_font_name, default_font_aspect_ratio, default_font_size, "LEFT", "TOP", agt_bx, agt_by);
  } // END METHOD show_agents_and_tag


  void draw_unit_agents() {
    //println("draw_unit_agents: " + unit_agents_counter);
    if (unit_agents_counter>0) {
      float arc_interval = TWO_PI / unit_agents_counter; 
      for (int i=0; i<unit_agents_counter; i++) {
        Agent a = searchAgent(unit_agents[i]);
        if (a!=null && !a.deleted) {
          stroke(a.agent_color); strokeWeight(margin); // stroke(grey_level); // color: grey filling
          arc(x, y, w+margin, h+margin, i*arc_interval, (i+1)*arc_interval);
        }
      }
    }
  }
  
  void add_unit_agent(String agt_name) {
    String agt_name_aux = agt_name;
    if (agt_name.equals("NULL")) {
      agt_name_aux = showInputDialog("Please enter agent");
      // if (text_aux == null) exit(); else
      if (agt_name_aux == null || agt_name_aux.equals(""))
        showMessageDialog(null, "Empty input!", "Alert", ERROR_MESSAGE);
      else if (searchStringIndex(agt_name_aux, unit_agents, 0, unit_agents_counter)!=-1)
        showMessageDialog(null, "Agent \"" + agt_name_aux + "\" already in this unit!!!", "Alert", ERROR_MESSAGE);
      else
        showMessageDialog(null, "Agent \"" + agt_name_aux + "\" successfully added to unit!!!", "Info", INFORMATION_MESSAGE);
    }
    if (searchStringIndex(agt_name_aux, unit_agents, 0, unit_agents_counter)==-1) {
      unit_agents[unit_agents_counter++]=agt_name_aux;
      update_agents(agt_name_aux, "ADD");
    }
  }

  void delete_unit_agent(String agt_name) {
    int agent_index = searchStringIndex(agt_name, unit_agents, 0, unit_agents_counter);
    if (agent_index!=-1) {
      unit_agents = deleteStringByIndex(agent_index, unit_agents);
      unit_agents_counter--;
    } else {showMessageDialog(null, "Agent not in unit!", "Alert", ERROR_MESSAGE);}
  }

  void modify_agent_name(String old_name, String new_name) {
    replaceString(old_name, new_name, unit_agents, 0, unit_agents_counter);
  }

  void delete_tension_name() {
    if (unit_tension_name.equals(tensions[i_select_tension].name)) {
      unit_tension_name = "NULL"; // assign NULL
      y = tension_position(50)/zoom-yo; // update unit vertical position with middle position
    } else {showMessageDialog(null, "Different tension selected!", "Alert", ERROR_MESSAGE);}
  }

  void modify_tension_name(String new_name) {
    unit_tension_name = new_name; // assign new tension name
    Tension t = search_tension(unit_tension_name); // search tension by name
    y = tension_position(t.tension_value)/zoom-yo; // update unit vertical position with tension value
  }

  void modify_tension_name_from_checkbox() {
    if (cur_unit_tension_index==-1) {unit_tension_name = "NULL";}
    else {unit_tension_name = tensions[cur_unit_tension_index].name;}
    if (!unit_tension_name.equals("NULL")) {
      Tension t = search_tension(unit_tension_name); // search tension by name
      y = tension_position(t.tension_value)/zoom-yo; // update unit vertical position with tension value
    }
    else {y = tension_position(50)/zoom-yo;}
    // hide_all_menus();     
  }

  //void show_tension() {
  //  if (plot_generation_mode == "TENSION") {
  //  // println("showing tension"); 
  //  int number_of_items = tensions_checkbox.getItems().size();
  //  if (unique_event) {
  //    unique_event=false;
  //    for (int j=0; j<number_of_items; j++) {tensions_checkbox.getItem(j).setState(false);} // all items initialized to false
  //    if (!unit_tension_name.equals("NULL")) {
  //      int t_index = search_tension_index(unit_tension_name); 
  //      tensions_checkbox.getItem(t_index).setState(true);
  //    }
  //    //tensions_checkbox.setPosition((x-w/2-tensions_checkbox.getWidth())*zoom+xo,y*zoom+yo).show();
  //    tensions_checkbox.setPosition((x+w/2)*zoom+xo,y*zoom+yo).show();
  //    //float bx = check_horizontal_boundaries(x-(tensions_checkbox.getWidth()+3*default_font_width), tensions_checkbox.getWidth()+3*default_font_width);
  //    //float by = check_vertical_boundaries(y-tensions_checkbox.getHeight(), tensions_checkbox.getHeight());
  //    //tensions_checkbox.setPosition(bx*zoom+xo,by*zoom+yo).show();
  //  }
  //  unique_event = true;
  //  }
  //}

  void show_tension() { // display the tension assigned to the unit
    float bx = x; float by = y; // center coordinates of tension box rectangle initially set to unit center
    String tension_box_text = "TENSION " + unit_tension_name;
    String[] words = split_text_into_words (tension_box_text);
    float[] box_size = determine_box_size(words, default_font_aspect_ratio, default_font_size);
    float box_width = box_size[0];  
    float box_height = box_size[1]; 
    bx = check_horizontal_boundaries(x+w/2+box_width/2, box_width); // display at the right
    by = check_vertical_boundaries(y+box_height/2, box_height); //  display below
    fill(0, 0, 100); //tbackground); WHITE background
    noStroke(); rectMode(CENTER);  
    rect(bx, by, box_width, box_height); 
    write_lines_in_fixed_fontsize(tension_box_text, default_font_name, default_font_aspect_ratio, default_font_size, "LEFT", "TOP", bx, by);
  } // END METHOD show_tension


} // END UNIT CLASS
