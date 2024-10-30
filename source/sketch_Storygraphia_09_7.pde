import controlP5.*;
import processing.net.*;
import garciadelcastillo.dashedlines.*; // library for dashed lines 
import static javax.swing.JOptionPane.*; // library for text input 

import java.awt.Dimension;
import java.awt.FlowLayout;
import javax.swing.JFrame;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;

String storygraphia_license = "credits: Vincenzo Lombardo, released under GNU General Public License version 3";
String graph_name = "NULL";
PImage sg_logo, sg_menu, twine_logo, ollama_logo;
String[] plot_generation_modes = {"MANUAL","PAINTING","SCULPTING","TENSION","PROPP"};

// ----------- SETTINGS ----------
void settings() {  
  generic_layout_settings(); // LAYOUT 
  help_settings(); // HELP LAYOUT
  generic_graph_settings(); // GRAPH
  // SPECIFIC SETTINGS
  unit_settings();
  agents_settings();
  tags_settings();
  // propp_settings();
  states_settings();
  tensions_settings();

  sg_logo = loadImage("SG_logo_trasp.png"); // 308x202  
  twine_logo = loadImage("Twine_logo_trasp.png"); // 320x322  
  ollama_logo = loadImage ("Ollama.png");
  sg_button = new imgButton(sg_logo, "Reset narrative! Unsaved changes will be lost.", (left_offset/2)/zoom-xo, (top_offset/2)/zoom-yo, left_offset, top_offset);
  twine_button = new imgButton(twine_logo, "Export to Twine (basic Harlowe format)", (1.5*left_offset)/zoom-xo, (top_offset/2)/zoom-yo, left_offset, top_offset);
  ollama_button = new imgButton(ollama_logo, "Invoca Ollama!!!", (3*left_offset)/zoom-xo, (top_offset/2)/zoom-yo, left_offset, top_offset);
  sg_menu = loadImage("Storygraphia_menu.png"); // 720x405
}

// ----------- SETUP ----------
void setup() { 
  // GENERIC SETUPS
  text_setup(); // text settings
  color_setup(); 
  // Initialize dashed lines, passing a reference to the current PApplet
  dash = new DashedLines(this);
  // Set the dash-gap pattern in pixels
  dash.pattern(10, 5);

  initial_page_setup(); 
  nav_edt_setup(); 
  man_prp_ptg_tns_setup(); 
  // SPECIFIC SETUPS
  generic_graph_setup();
  story_specific_setup();
  // menu_checkbox_setup();
} // end setup

// ----------- DRAW ----------
void draw() {
  background(0, 0, 100); // white background
  stroke(edge_color); 
  fill(node_color); 
  rectMode(CENTER); 
  // draw_agents(); draw_tags();
  if (!graph_name.equals("NULL")) {draw_header(); draw_footer();} // this makes graphics stable

  pushMatrix();
  translate (xo, yo);
  scale (zoom);
  // if (plot_generation_mode.equals("PROPP")) {propp_layout_bg_matrix();} // Propp background 
  // initialization 
  switch(modality) {
  case "INI": // *********** INITIALIZATION *************
    storygraphia_license_setup();
    initialization_choice(); 
    break;      
  case "PRP": // *********** LAYOUT PREPARATION ************* 
    modality="EDT"; nav_edt_button.text = "EDT";
    if (plot_generation_mode.equals("PAINTING")) {man_prp_ptg_tns_switch_button.text=ptg_text;} // || plot_generation_mode.equals("SCULPTING")
    else if (plot_generation_mode.equals("TENSION")) {man_prp_ptg_tns_switch_button.text=tns_text; tension_bg_setup();} 
    else if (plot_generation_mode.equals("PROPP")) {man_prp_ptg_tns_switch_button.text=prp_text;}  
    else {man_prp_ptg_tns_switch_button.text=man_text;} // (MANUAL) 
    break;      
  // =============================================================
  // ========================= EDT ===============================
  // =============================================================
  case "EDT": // *********** EDITING *************
    // DRAWING
    // *** background
    if (plot_generation_mode.equals("PAINTING") || plot_generation_mode.equals("SCULPTING")) {constraints_layout_bg();} // Pre-effs background 
    else if (plot_generation_mode.equals("TENSION")) {tension_layout_bg();} // Tension arc background
    else if (plot_generation_mode.equals("PROPP")) {propp_layout_bg_matrix(); draw_propp_functions();} // Propp background 
    else {background(0, 0, 100);} // (MANUAL) white background
    if (white_page) {
      flex_write_lines_in_box("Press 'h' for help", default_font_name, default_font_aspect_ratio, 
                              "CENTER", "CENTER", width/2-xo, height-bottom_offset-yo, width-left_offset*2, y_credits);
    }
    draw_agents(); draw_tags(); draw_header(); draw_footer();
    if (plot_generation_mode.equals("PAINTING") || plot_generation_mode.equals("SCULPTING")) {draw_states(); state_layover();} // draw states the mode is PRE-EFFs
    else if (plot_generation_mode.equals("TENSION")) {draw_tensions(); tension_layover();} // draw states the mode is TENSION
    else if (plot_generation_mode.equals("PROPP")) {draw_propp_functions(); pf_layover();} // draw states the mode is PROPP
    // *** header
    // if (!graph_name.equals("NULL")) {draw_header();}
    // *** draw edges
    draw_labelled_edges();
    // *** draw nodes
    for (int i=0; i<i_cur_node; i++) {
      Unit u = (Unit) nodes[i]; 
      u.draw_unit();
    } 
    if (!select_type.equals("NULL")) {story_show_menus();} 
    // *** layover
    else {layover(); agent_layover(); tag_layover(); button_layover();} 
    if (help_b) {display_help();}
    break;
  // =============================================================
  // ======================= NAV =================================
  // =============================================================
  case "NAV": // *********** NAVIGATING THE GRAPH *************
    draw_agents(); draw_tags(); 
    // *** header
    if (!graph_name.equals("NULL")) {draw_header();}
    // set the cur_nav_unit
    next_node_in_nav();
    // find predecessor and subsequent units
    // set positions for adjacent unit and related edges
    // *** draw edges
    Unit u_cur = (Unit) nodes[cur_nav_node_index];
    for (int i=0; i<i_cur_edge; i++) {
      if (searchStringIndex(plot_generation_mode, edges[i].pg_modes, 0, edges[i].pg_modes.length)!=-1 &&
          ((searchStringIndex(edges[i].tail_id, predecessor_node_ids, 0, i_cur_predecessor)!=-1 && 
          edges[i].head_id.equals(u_cur.id)) ||
          (searchStringIndex(edges[i].head_id, subsequent_node_ids, 0, i_cur_subsequent)!=-1 && 
          edges[i].tail_id.equals(u_cur.id))))
          {
        edges[i].draw_labelled_edge(); 
      }
    }; 
    // draw unit and edges
    for (int i=0; i<i_cur_node; i++) {
      Unit u = (Unit) nodes[i]; 
      if (i == cur_nav_node_index) {u.draw_unit_in_nav("cur");}
      else if (searchStringIndex(u.id, predecessor_node_ids, 0, i_cur_predecessor)!=-1) {
        u.draw_unit_in_nav("pre");}
      else if (searchStringIndex(u.id, subsequent_node_ids, 0, i_cur_subsequent)!=-1) {
        u.draw_unit_in_nav("sub");}
    } 
    // *** layover
    layover_nav(); agent_layover(); tag_layover(); // button_layover();
    break;
  } // end SWITCH
  popMatrix();
} // end draw



// *** STORY SPECIFIC INTERACTIVITY

void mouseClicked() {
  switch(modality) {
  case "INI": 
    story_initialization_go();
    break;
  case "EDT":
    // if mouse in the central editing area
    // if (mouseX < width-right_offset && mouseY > top_offset &&
       // mouseX > left_offset && mouseY < height) {
    // node selection (always possible)
    node_selection(); 
    // edge selection (not possible with SCULPTING and PAINTING)
    // if (plot_generation_mode.equals("MANUAL") || plot_generation_mode.equals("TENSION") || plot_generation_mode.equals("PROPP"))
      edge_selection();
    //} else
    // if mouse in the agent area
    // if (mouseX < left_offset && mouseY > top_offset &&
       // mouseX > 0 && mouseY < height) {
    // agent selection (always possible)
    agent_selection();
    // } else
    // if mouse in the tag area
    // if (mouseX < width && mouseY > top_offset &&
       // mouseX > width-right_offset && mouseY < height) {
    // tag selection (always possible)
    tag_selection();
    //} else
    // if mouse in the state area
    // if (mouseX < width && mouseY > height - bottom_offset &&
       //  mouseX > left_offset && mouseY < height) {
    // Propp function selection (only possible in PROPP mode)
    if (plot_generation_mode.equals("PROPP")) {pf_selection();}
    // tension selection (only possible in TENSION mode)
    else if (plot_generation_mode.equals("TENSION")) {tension_selection();} 
    // state selection (only possible in PAINTING and SCULPTING modes)
    else if (plot_generation_mode.equals("PAINTING") || plot_generation_mode.equals("SCULPTING")) {state_selection();}      
    // NAV/EDT button click (always possible)
    if (nav_edt_button.click_rectButton() && i_cur_node > 0) {nav_edt_go();} else
    // MAN/PRP/PTG/TNS button click (in EDT mode)
    if (man_prp_ptg_tns_switch_button.click_rectButton() && i_cur_node > 0) {man_prp_ptg_tns_go();} else
    // Twine export button click (always possible)
    if (twine_button.click_imgButton()) {twine_button_go();} else
    // SG button click --> story reset (always possible)
    if (sg_button.click_imgButton()) {
      initial_page_setup();
      // hide_all_menus();
      generic_graph_setup();
      // menu_checkbox_setup();
      story_specific_setup();
      modality = "INI";
    }
    break;
  case "NAV":
    // mouse in the NAV/EDT choice area
    if (nav_edt_button.click_rectButton()) {nav_edt_go();} else
    // if mouse in the central editing area
    //if (mouseX < width-right_offset && mouseY > top_offset &&
        //mouseX > left_offset && mouseY < height) {
      // selection of edge for advancing in navigation
      edge_selection_nav();
    //}
    break;
  }
}


void keyPressed() {  
  key_ok = false;
  switch(modality) {
  case "EDT":
    // =======================================
    // ========= SAVE AND EXPORT =============
    // =======================================
    if (key=='b') { // twine
      // ========= EXPORT TO TWINE HARLOWE =============
      selectOutput("Select a file to write to:", "write_twine_graph");      
      key_ok = true;
    } else
      // ========= SAVE TO STORYGRAPHIA JSON =============
      // ========= SAVE AS ... (NEW FILE) =============
    if (keyCode==SHIFT) { 
      graph_name = set_graph_name(); selectOutput("Select a file to write to:", "write_storygraph");
      headerStoryCountAndPrint();
      key_ok = true;
    } else
      // ========= SAVE (AS ...) =============
    if (key=='w') { 
      if (graph_name.equals("NULL")) {graph_name = set_graph_name(); selectOutput("Select a file to write to:", "write_storygraph");}
      else {write_storygraph(cur_selection); showMessageDialog(null, "Overwritten current file: " + cur_selection, "Info", INFORMATION_MESSAGE);}
      headerStoryCountAndPrint();
      key_ok = true;
    // ========= CANCEL =============
    } else if (key == 'z') {
      if (i_select_agent!=-1 && (select_type.equals("AGENT")||select_type.equals("NODE+AGENT"))) {
        i_select_agent=-1; select_type="NULL"; selection_possible = true;}  // hide_all_menus();
      if (i_select_agent!=-1 && (select_type.equals("STATE")||select_type.equals("NODE+STATE"))) {
        i_select_state=-1; select_type="NULL"; selection_possible = true;}  // hide_all_menus();
      if (i_select_agent!=-1 && (select_type.equals("TENSION")||select_type.equals("NODE+TENSION"))) {
        i_select_tension=-1; select_type="NULL"; selection_possible = true;}  // hide_all_menus();
      if (i_select_agent!=-1 && (select_type.equals("PROPP")||select_type.equals("NODE+PROPP"))) {
        i_select_pf=-1; select_type="NULL"; selection_possible = true;}  // hide_all_menus();
      if (i_select_node!=-1 && (select_type.equals("NODE+TENSION") || select_type.equals("NODE+PROPP") || select_type.equals("NODE+STATE") || select_type.equals("NODE+STATE"))) {
        nodes[i_select_node].select1 = false; i_select_node=-1; select_type="NULL"; selection_possible = true;  // hide_all_menus();
      }
      if (help_b) {help_b = false;} // exit from help
      key_ok = true;
    // ========= CREATE UNIT =============
    } else if (key=='u') { // create a new unit 
      if (i_select_node==-1) {
        nodes[i_cur_node++]=new Unit(0, 0, diameter_size, diameter_size, "N" + str(hour()) + str(minute()) + str(second()) + node_counter++, "NULL", "NULL TAG");                                        
      }
      key_ok = true;
    // =======================================
    // ========= DELETE AND DETACH =============
    // =======================================
    } else if (key=='d') { 
      // ========= DELETE AGENT: delete the selected agent from the whole story
      if (select_type=="AGENT" && i_select_agent!=-1) {
        // hide_all_menus(); agents[i_select_agent].delete();
        i_select_agent=-1; select_type="NULL"; selection_possible = true;
      } 
      // ========= DETACH AGENT: detach the selected agent from the selected unit
      else if (select_type=="NODE+AGENT" && i_select_node!=-1 && i_select_agent!=-1) {
        // hide_all_menus();
        Unit u = (Unit) nodes[i_select_node]; Agent a = agents[i_select_agent];
        u.delete_unit_agent(a.name); 
        nodes[i_select_node].select1 = false; i_select_node=-1; 
        i_select_agent=-1; 
        select_type="NULL"; selection_possible = true; 
      }
      // ========= DELETE TENSION: delete the selected tension from the whole story
      else if (select_type=="TENSION" && i_select_tension!=-1) {
        // hide_all_menus(); 
        tensions[i_select_tension].delete();
        i_select_tension=-1; select_type="NULL"; selection_possible = true;
      } 
      // ========= DETACH TENSION: detach the selected tension from the selected unit
      else if (select_type=="NODE+TENSION" && i_select_node!=-1 && i_select_tension!=-1) {
        // hide_all_menus();
        Unit u = (Unit) nodes[i_select_node]; Tension t = tensions[i_select_tension];
        u.delete_tension_name(); 
        nodes[i_select_node].select1 = false; i_select_node=-1; 
        i_select_tension=-1; select_type="NULL"; selection_possible = true; 
      // ========= DELETE STATE: delete the selected state from the whole story
      } else if (select_type=="STATE" && i_select_state!=-1) {
        // hide_all_menus(); update_states(states[i_select_state].name,"DEL");
        i_select_state=-1; select_type="NULL"; selection_possible = true;
      } 
      // ========= DETACH STATE: detach the selected state from the selected unit
      else if (select_type=="NODE+STATE" && i_select_node!=-1 && i_select_state!=-1) {
        // hide_all_menus();
        Unit u = (Unit) nodes[i_select_node]; State s = states[i_select_state];
        u.delete_unit_precondition(s.name);// u.delete_unit_precondition(s.id); 
        u.delete_unit_effect(s.name); // u.delete_unit_effect(s.id); 
        nodes[i_select_node].select1 = false; i_select_node=-1; i_select_state=-1; 
        select_type="NULL"; selection_possible = true; 
      }
      // ========= DETACH PROPP FUNCTION: detach the selected propp function from the selected unit
      else if (select_type=="NODE+PROPP" && i_select_node!=-1 && i_select_pf!=-1) {
        // hide_all_menus();
        Unit u = (Unit) nodes[i_select_node]; 
        if (u.unit_propp_tag_index == i_select_pf) {
          cur_unit_propp_tag_index = -1; u.modify_propp_tag(); // modify the propp tag
        } else {showMessageDialog(null, "Different Propp tag selected!", "Alert", ERROR_MESSAGE);}
        nodes[i_select_node].select1 = false; i_select_node=-1;  // unselect node
        propp_functions[i_select_pf].selected = false; i_select_pf=-1; // unselect pf
        select_type="NULL"; selection_possible = true; // section possible again
      }
    // } else if (key=='m') { // move a node
      //if (!select_type.equals("AGENT") && i_move!=-1) {// hide_all_menus();} 
      key_ok = true;
    // ======================================
    // ====  PROPP (ONLY IN PROPP MODE)  ====
    // ======================================
    } else if (key=='r' && plot_generation_mode.equals("PROPP")) { 
      // modify through buttons
      if (select_type=="NODE+PROPP" && i_select_node!=-1 && i_select_pf!=-1) {
        Unit u = (Unit) nodes[i_select_node]; Propp_function pf = propp_functions[i_select_pf]; 
        cur_unit_propp_tag_index = i_select_pf;
        u.modify_propp_tag(); // modify the tags through the checkbox
        nodes[i_select_node].select1 = false; i_select_node=-1;  // unselect node
        propp_functions[i_select_pf].selected = false; i_select_pf=-1; // unselect pf
        select_type="NULL"; selection_possible = true; // section possible again
      } else
      // modify through menu
      if (select_type=="NODE" && i_select_node!=-1) {
        Unit u = (Unit) nodes[i_select_node]; u.modify_propp_tag(); // modify the tags through the checkbox
        nodes[i_select_node].select1 = false; i_select_node=-1; select_type="NULL"; selection_possible = true; // unselect
      }
      key_ok = true;
    // =======================================================
    // ====  STATE (ONLY IN PAINTING AND SCULPTING MODE)  ====
    // =======================================================
    } else if (key=='s' && (plot_generation_mode.equals("PAINTING") || plot_generation_mode.equals("SCULPTING"))) { 
    // ========= CREATE STATE =============
      if (select_type=="NULL") {
        String state_name = create_state();
        update_states(state_name, "ADD");
      }
      key_ok = true;
    } else if (key=='p' && (plot_generation_mode.equals("PAINTING") || plot_generation_mode.equals("SCULPTING"))) {
    // ========= ADD PRECONDITION OR MODIFY PRECONDITION LIST OF UNIT =============
      if (select_type=="NODE+STATE" && i_select_node!=-1 && i_select_state!=-1) {
        // hide_all_menus();
        Unit u = (Unit) nodes[i_select_node]; State state = states[i_select_state];
        u.add_unit_precondition(state.name);
        nodes[i_select_node].select1 = false; i_select_node=-1; i_select_state=-1; select_type="NULL"; selection_possible = true; 
      //} else if (select_type=="NODE" && i_select_node!=-1 && i_select_state==-1) {
      //  Unit u = (Unit) nodes[i_select_node]; 
      //  u.modify_preconditions_from_checkbox(); // modify the preconditions through the checkboxes
      //  nodes[i_select_node].select1 = false; i_select_node=-1; select_type="NULL"; selection_possible = true; // unselect
      }
      key_ok = true;
    } else if (key=='f' && (plot_generation_mode.equals("PAINTING") || plot_generation_mode.equals("SCULPTING"))) {  
    // ========= ADD EFFECT OR MODIFY EFFECT LIST OF UNIT =============
      if (select_type=="NODE+STATE" && i_select_node!=-1 && i_select_state!=-1 && 
          (plot_generation_mode.equals("PAINTING") || plot_generation_mode.equals("SCULPTING"))) {
        // hide_all_menus();
        Unit u = (Unit) nodes[i_select_node]; State state = states[i_select_state];
        u.add_unit_effect(state.name); 
        nodes[i_select_node].select1 = false; i_select_node=-1; i_select_state=-1; select_type="NULL"; selection_possible = true; 
      }
      key_ok = true;
    // ==========================================
    // ===== TENSION (ONLY IN TENSION MODE) =====
    // ==========================================
    } else if (key=='y' && (plot_generation_mode.equals("TENSION"))) { 
      // ========= CREATE TENSION =============
      if (select_type=="NULL") {
        String tension_name = create_tension();
        update_tension_lists(tension_name, 50, "ADD");
      } else
      // ========= MODIFY TENSION VALUE =============
      if (select_type=="TENSION" && i_select_tension!=-1) {
        // hide_all_menus();
        Tension t = (Tension) tensions[i_select_tension]; 
        t.modify_tension_value();  // modify the tension value through the input dialog
        tension_layout_update(t.name); // update all the y positions of units
        i_select_tension=-1; select_type="NULL"; selection_possible = true; // unselect
      } else
      // ========= MODIFY UNIT TENSION FROM MENU =============
      if (select_type=="NODE" && i_select_node!=-1) {
        Unit u = (Unit) nodes[i_select_node]; // u.modify_tension_name_from_checkbox(); // modify the tension through the checkbox
        nodes[i_select_node].select1 = false; i_select_node=-1; select_type="NULL"; selection_possible = true; // unselect
      } else 
      // ========= ASSIGN TENSION TO A UNIT =============
      if (select_type=="NODE+TENSION" && i_select_node!=-1 && i_select_tension!=-1) {
        // hide_all_menus();
        Unit u = (Unit) nodes[i_select_node]; 
        Tension t = tensions[i_select_tension];
        u.modify_tension_name(t.name);
        // u.unit_tension_name = t.name;
        // add tension to the unit
        nodes[i_select_node].select1 = false; i_select_node=-1; i_select_tension=-1; 
        select_type="NULL"; selection_possible = true; // unselect
      }
      key_ok = true;
    // ===============================
    // ========= AGENT =============
    // ===============================
    } else if (key=='a') { // STORY SPECIFIC: add a new agent in a unit 
      // ========= CREATE AGENT AND ADD TO UNIT =============
      if (select_type=="NODE" && i_select_node!=-1) {
        // hide_all_menus();
        Unit u = (Unit) nodes[i_select_node];
        u.add_unit_agent("NULL"); 
        nodes[i_select_node].select1 = false; node_deselection(); // i_select_node=-1; select_type="NULL"; selection_possible = true; 
      } 
      // ========= ADD AGENT TO UNIT =============
      else if (select_type=="NODE+AGENT" && i_select_node!=-1 && i_select_agent!=-1) {
        // hide_all_menus();
        Unit u = (Unit) nodes[i_select_node]; Agent a = agents[i_select_agent];
        u.add_unit_agent(a.name); 
        nodes[i_select_node].select1 = false; i_select_node=-1; 
        i_select_agent=-1; 
        select_type="NULL"; selection_possible = true; 
      }
      key_ok = true;
    // ========= MODIFY TEXT =============
    } else if (key=='t' && !select_type.equals("NULL")) { // modify the text of the selected agent
      if (select_type=="AGENT" && i_select_agent!=-1) {
        // hide_all_menus();
        agents[i_select_agent].modify_name(); // modify the text
        i_select_agent=-1; select_type="NULL"; selection_possible = true; // unselect
      } else
      if (select_type=="STATE" && i_select_state!=-1) {
        // hide_all_menus();
        states[i_select_state].modify_name(); // modify the text
        i_select_state=-1; select_type="NULL"; selection_possible = true; // unselect
      } else
      if (select_type=="TENSION" && i_select_tension!=-1) {
        // hide_all_menus();
        tensions[i_select_tension].modify_name(); // modify the text
        i_select_tension=-1; select_type="NULL"; selection_possible = true; // unselect
      }
      key_ok = true;
    } // else {  
    // }      
    break;
  }
  // println("GENERIC KEYPRESS");
  generic_graph_keyPressed();
  if (!key_ok) {showMessageDialog(null, "No action! Press 'h' for help!", "Alert", ERROR_MESSAGE);}
}

// *** STORY SPECIFIC SETUP

void storygraphia_license_setup() { 
  // flex_write_lines_in_box(String text, font_type, float font_aspect_ratio, String x_align, String y_align, float x_center, float y_center, float x_width, float y_height)
  imageMode(CENTER); image(sg_logo, width/2-xo, 3*y_credits-yo, sg_logo.width*2*y_credits/sg_logo.height, 2*y_credits);
  flex_write_lines_in_box("STORYGRAPHIA 0.9.6", default_font_name, default_font_aspect_ratio, "CENTER", "CENTER", width/2-xo, y_credits-yo, width-y_credits*2, y_credits);
  flex_write_lines_in_box(storygraphia_license, default_font_name, default_font_aspect_ratio, "CENTER", "CENTER", width/2-xo, height-bottom_offset-yo, width-left_offset*2, y_credits);
} 

void story_specific_setup() {
  tags_setup();
  agents_setup(); 
  propp_setup();
  states_setup();
  // tension_bg_setup();
  tensions_setup();
}

void story_initialization_go() {
  // println("story_initialization_go");
  if (scratch_button.click_rectButton()) {
    modality="PRP"; plot_generation_mode = "MANUAL"; white_page=true;
  } else if (file_button.click_rectButton()) {
    selectInput("Select a file to process:", "load_storytext"); 
    modality="PRP"; plot_generation_mode = "MANUAL";
  //} else if (load_button.click_rectButton()) {
  //  selectInput("Select a file to process:", "load_storygraph"); 
  //  modality="PRP"; plot_generation_mode = "MANUAL";
  } else if (manual_button.click_rectButton()) {
    selectInput("Select a file to process:", "load_storygraph"); 
    modality="PRP"; plot_generation_mode = "MANUAL";
  } else if (propp_button.click_rectButton()) {
    selectInput("Select a file to process:", "load_storygraph"); 
    modality="PRP"; plot_generation_mode = "PROPP";
  //} else if (constraints_sculpting_button.click_rectButton()) {
  //  selectInput("Select a file to process:", "load_storygraph"); 
  //  modality="PRP"; plot_generation_mode = "SCULPTING";
  } else if (constraints_painting_button.click_rectButton()) {
    selectInput("Select a file to process:", "load_storygraph"); 
    modality="PRP"; plot_generation_mode = "PAINTING";
  } else if (arc_button.click_rectButton()) {
    selectInput("Select a file to process:", "load_storygraph"); 
    modality="PRP"; plot_generation_mode = "TENSION";
  }
}

void nav_edt_go() {
  // hide_all_menus();
  if (modality.equals("EDT") && nav_edt_button.click_rectButton()) {
    nav_edt_button.text = "NAV";
    select_start_node_in_nav();
    modality="NAV"; 
  } else if (modality.equals("NAV") && nav_edt_button.click_rectButton()) {
    nav_edt_button.text = "EDT";
    modality="EDT"; cur_nav_node_index=-1;
  } 
}

void man_prp_ptg_tns_go() {
  // hide_all_menus();
  if (modality.equals("EDT") && man_prp_ptg_tns_switch_button.click_rectButton()) {
    if (plot_generation_mode.equals("MANUAL")) {plot_generation_mode = "PROPP";} else
    if (plot_generation_mode.equals("PROPP")) {plot_generation_mode = "PAINTING";} else
    if (plot_generation_mode.equals("PAINTING")) {plot_generation_mode = "TENSION";} else
    if (plot_generation_mode.equals("TENSION")) {plot_generation_mode = "MANUAL";} 
    modality = "PRP";
  } 
}

void twine_button_go() {
  // hide_all_menus();
  if (twine_button.click_imgButton()) {
    selectOutput("Select a file to write to:", "write_twine_graph");
    modality="EDT"; cur_nav_node_index=-1;
  } 
}

void select_start_node_in_nav() {
  if (i_select_node!=-1) {cur_nav_node_index = i_select_node; nodes[i_select_node].select1=false; node_deselection(); } // i_select_node=-1; selection_possible=true; } 
  else {
    boolean cur_nav_node_index_found = false;
    while (!cur_nav_node_index_found) {
      int cur_nav_node_index_proposal = int(random(i_cur_node));
      if (!nodes[cur_nav_node_index_proposal].deleted) {
        cur_nav_node_index=cur_nav_node_index_proposal;
        cur_nav_node_index_found=true;
      }
    }
  }
  nodes[cur_nav_node_index].x_nav=0; nodes[cur_nav_node_index].y_nav=0;
  nodes[cur_nav_node_index].w_nav=actual_height/3; nodes[cur_nav_node_index].h_nav=actual_height/3;
  nodes[cur_nav_node_index].compute_pred_subs();
  float offset = actual_height/i_cur_predecessor;
  for (int i=0; i<i_cur_predecessor; i++) {
    int node_index = searchNodeIdIndex(predecessor_node_ids[i]);
    nodes[node_index].y_nav = (top_offset + i * offset + offset/2)/zoom-yo;
    nodes[node_index].x_nav = (left_offset+actual_width/6)/zoom-xo;
    nodes[node_index].w_nav=diameter_size;
    nodes[node_index].h_nav=diameter_size;
  }
  offset = actual_height/i_cur_subsequent;
  for (int i=0; i<i_cur_subsequent; i++) {
    int node_index = searchNodeIdIndex(subsequent_node_ids[i]);
    nodes[node_index].y_nav = (top_offset + i * offset + offset/2)/zoom-yo;
    nodes[node_index].x_nav = (left_offset+5*actual_width/6)/zoom-xo;
    nodes[node_index].w_nav=diameter_size;
    nodes[node_index].h_nav=diameter_size;
  }
}

void next_node_in_nav() {
  for (int i=0; i<i_cur_node; i++) {
    nodes[i].x_nav=-1; nodes[i].y_nav=-1;
    nodes[i].w_nav=0; nodes[i].h_nav=0;
  }
  for (int i=0; i<i_cur_edge; i++) {
    edges[i].label_x_nav=-1; edges[i].label_y_nav=-1;
  }
  nodes[cur_nav_node_index].x_nav=0; nodes[cur_nav_node_index].y_nav=0;
  nodes[cur_nav_node_index].w_nav=actual_height/3; nodes[cur_nav_node_index].h_nav=actual_height/3;
  nodes[cur_nav_node_index].compute_pred_subs();
  float offset = actual_height/i_cur_predecessor;
  for (int i=0; i<i_cur_predecessor; i++) {
    int node_index = searchNodeIdIndex(predecessor_node_ids[i]);
    nodes[node_index].y_nav = (top_offset + i * offset + offset/2)/zoom-yo;
    nodes[node_index].x_nav = (left_offset+actual_width/6)/zoom-xo;
    nodes[node_index].w_nav=diameter_size;
    nodes[node_index].h_nav=diameter_size;
  }
  offset = actual_height/i_cur_subsequent;
  for (int i=0; i<i_cur_subsequent; i++) {
    int node_index = searchNodeIdIndex(subsequent_node_ids[i]);
    nodes[node_index].y_nav = (top_offset + i * offset + offset/2)/zoom-yo;
    nodes[node_index].x_nav = (left_offset+5*actual_width/6)/zoom-xo;
    nodes[node_index].w_nav=diameter_size;
    nodes[node_index].h_nav=diameter_size;
  }
}

void story_show_menus() {
  if (i_select_node!=-1) {
    Unit u;
    switch(plot_generation_mode) {
      case "MANUAL": 
        // nodes[i_select_node].show_tags();
        // nodes[i_select_node].show_tag();
        u = (Unit) nodes[i_select_node];
        u.show_agents_and_tag();
        break;
      case "PAINTING": 
        u = (Unit) nodes[i_select_node];
        // u.show_states();
        u.show_preconditions_and_effects();
        break;
      case "SCULPTING": 
        u = (Unit) nodes[i_select_node];
        // u.show_states();
        u.show_preconditions_and_effects();
        break;
      case "TENSION": 
        u = (Unit) nodes[i_select_node];
        // u.show_tags();
        u.show_tension();
        break;
      case "PROPP": 
        u = (Unit) nodes[i_select_node];
        // u.show_tags();
        u.show_propp_tag();
        break;
    }
  }
}
