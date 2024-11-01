// GRAPH NODES: GLOBAL VARIABLES
int totalNum; 
// int num = 0; 
// int num_deleted = 0;
Node[] nodes; // array of nodes
int i_cur_node = 0; // cursor on nodes
int node_counter = 0;
// int[] deleted_nodes; // nodes deleted in one session
float diameter_size; 
float cur_node_size_in_nav;
color node_color;
// NAV variables
String[] predecessor_node_ids; // predecessor node ids of the current node in NAV mode
String[] subsequent_node_ids; // subsequent nodes of the current node in NAV mode
int i_cur_predecessor; int i_cur_subsequent; // total of predecessor and subsequent, respectively

void generic_graph_settings() {
  totalNum = 1000; 
  total_num_edges=totalNum^2;
  nodes = new Node[totalNum];
  edges = new Edge[total_num_edges];
  // deleted_nodes = new int[totalNum]; 
  predecessor_node_ids = new String[totalNum]; i_cur_predecessor=-1;
  subsequent_node_ids = new String[totalNum]; i_cur_subsequent=-1;
}

void generic_graph_setup() {
  graph_name = "NULL";
  i_cur_node = 0;
  i_cur_edge = 0; i_cur_painting_edge=0; i_cur_sculpting_edge=0;
  i_cur_predecessor=-1;
  i_cur_subsequent=-1;
}

class Node {
  float x,y; // node center coordinates
  float x_nav, y_nav; // temporary coordinates for navigation
  float w,h; // node circle width and height, respectively
  float w_nav,h_nav; // temporary sizes for navigation
  String id; // node identifier
  String text; // node text
  // String[] node_tags; int node_tags_counter; // node tags and counter 
  String node_tag;
  String media_type; // image (PNG, JPG), video, audio
  PImage node_image;
  
  // CheckBox[] node_menu_tags; // ListBox menu_tag; // DropdownList menu_tag;
  
  ToolTip tooltip;
  boolean select1, select2, deleted;

  Node(float x_aux, float y_aux, float w_aux, float h_aux, String id_aux, String text_aux, String tag_name_aux) {
    x=x_aux; y=y_aux; w=w_aux; h=h_aux; id=id_aux; text=text_aux; select1=false; select2=false; deleted=false;
    // node_tags = new String[total_tags]; node_tags_counter = 0; 
    node_tag = "NULL TAG";
    // THREE LINES UNUSED
    // if (!tag_name_aux.equals("NULL TAG")) {
      // node_tags[node_tags_counter++]=tag_name_aux; update_tag_lists(tag_name_aux, "ADD");
    // }
    // Tooltip_box(String i, String tt, float xc, float yc, float xw, float yh)
    tooltip = new ToolTip(text, x, y-w, size_x/2, size_y/2, default_font_name, default_font_size, default_font_aspect_ratio);
    media_type="NULL";
  }

  // adds a tag to a node, possibly creating it 
  void add_node_tag(String tag_name) { 
    String tag_name_aux = tag_name;
    if (tag_name_aux.equals("NULL")) {tag_name_aux = create_tag();}
    // if (searchStringIndex(tag_name_aux, node_tags, 0, node_tags_counter)==-1) {
    //  node_tags[node_tags_counter++]=tag_name_aux;
    //  update_tag_lists(tag_name_aux, "ADD");
    //}
    node_tag = tag_name_aux;
    update_tag_lists(tag_name_aux, "ADD");
  }

  void delete_node_tag(String tag_name) {
    // int tag_index = searchStringIndex(tag_name, node_tags, 0, node_tags_counter);
    //if (tag_index!=-1) {
    //  node_tags = deleteStringByIndex(tag_index, node_tags);
    //  node_tags_counter--;
    // }
    if (tag_name.equals(node_tag)) {node_tag = "NULL TAG";
    } else {showMessageDialog(null, "Different tag selected!", "Alert", ERROR_MESSAGE);}
  }

  void modify_tag_name(String old_name, String new_name) {
    // replaceString(String old_name, String new_name, String[]list, int left, int right)
    // replaceString(old_name, new_name, node_tags, 0, node_tags_counter);
    if (old_name.equals(node_tag)) {node_tag = new_name;
    } else {showMessageDialog(null, "Different tag selected!", "Alert", ERROR_MESSAGE);}    
  }

  //void modify_tags() {
  //  // print("modifying tags:"); for (int j=0; j<node_tags_counter; j++) {print(" " + node_tags[j]);} print("\n");
  //  print4check("current tags:", 0, node_tags_counter, node_tags);
  //  node_tags_counter = 0; int i=0; // initialize_tag_list(node_tags);
  //  // print ("\n tags_checkbox items: "); for (int j=0; j<tags_checkbox.getItems().size(); j++) {print(tags_checkbox.getItem(j).getName() + " ");} print("\n");
  //  // print4check("cur_node_tags_from_checkbox: ", 0, 10, cur_node_tags_from_checkbox);
  //  while (!cur_node_tags_from_checkbox[i].equals("NULL TAG") && i<cur_node_tags_from_checkbox.length) {
  //    // println("modify_tags: " + cur_node_tags_from_checkbox[i]); 
  //    node_tags[node_tags_counter] = cur_node_tags_from_checkbox[i];
  //    node_tags_counter++; i++;
  //  }
  //  // hide_all_menus(); // tags_checkbox.hide();
  //  // initialize_tag_list(cur_node_tags_from_checkbox); // reset the temporary list of tags
  //  // println("modified tags:"); for (int j=0; j<node_tags_counter; j++) {print(" " + node_tags[j]);}
  //}

  // OBSOLETE: BASED ON MENUS
  //void show_tags() { 
  //  // println("showing tags:"); for (int j=0; j<node_tags_counter; j++) {print(" " + node_tags[j]);}
  //  int number_of_items = tags_checkbox.getItems().size();
  //  for (int j=0; j<number_of_items; j++) {tags_checkbox.getItem(j).setState(false);} // all items initialized to false
  //  for (int i=0; i<node_tags_counter; i++) { // for each tag of this node
  //    for (int j=0; j<number_of_items; j++) { // for each item of tag checkbox
  //      if (tags_checkbox.getItem(j).getName().equals(node_tags[i])) { // if the two names coincide
  //        tags_checkbox.getItem(j).setState(true);} // set item state to true 
  //    }
  //  }      
  //  tags_checkbox.setPosition((x+w/2)*zoom+xo,y*zoom+yo).show();
  //}

  void show_tag() { // display the tag over the unit
    float bx = x; float by = y; // center coordinates of tag box rectangle initially set to unit center
    // String tag_box_text = "TAG "+node_tags[0];
    String tag_box_text = "TAG "+node_tag;
    String[] words = split_text_into_words (tag_box_text);
    float[] box_size = determine_box_size(words, default_font_aspect_ratio, default_font_size);
    float tag_box_width = box_size[0]; // id_general_length*default_font_width; 
    float tag_box_height = box_size[1]; // 2*default_font_size; // 2 lines TAG \n tag_id
    bx = check_horizontal_boundaries(x+w/2+tag_box_width/2, tag_box_width); // display at the right
    by = check_vertical_boundaries(y+tag_box_height/2, tag_box_height); // same y
    fill(0, 0, 100); //tbackground); WHITE background
    noStroke(); rectMode(CENTER);  
    rect(bx, by, tag_box_width, tag_box_height); 
    // fill(text_color); // BLACK text
    write_lines_in_fixed_fontsize(tag_box_text, default_font_name, default_font_aspect_ratio, default_font_size, "LEFT", "TOP", bx, by);
  } // END METHOD show_tag


  void modify_text() {
    // public static String showInputDialog(Object message)
    // public static String showInputDialog(Object message, Object initialSelectionValue)
    // public static String showInputDialog(Component parentComponent, Object message)
    // public static String showInputDialog(Component parentComponent, Object message, Object initialSelectionValue)
    // public static String showInputDialog(Component parentComponent, Object message, String title,int messageType) 
    // public static Object showInputDialog(...) // throws HeadlessException
                     // Component parentComponent, --- - the parent Component for the dialog
                     // Object message, --- the Object to display
                     // String title, --- the String to display in the dialog title bar
                     // int messageType, --- the type of message to be displayed: ERROR_MESSAGE, INFORMATION_MESSAGE, WARNING_MESSAGE, QUESTION_MESSAGE, or PLAIN_MESSAGE
                     // Icon icon, --- the Icon image to display
                     // Object[] selectionValues, --- an array of Objects that gives the possible selections
                     // Object initialSelectionValue) ---  the value used to initialize the input field
    JTextArea textArea = new JTextArea(text);
    JScrollPane scrollPane = new JScrollPane(textArea);  
    textArea.setLineWrap(true);  
    textArea.setWrapStyleWord(true); 
    scrollPane.setPreferredSize(new Dimension(300, 200));
    String text_aux = showInputDialog(null, scrollPane, "Modify and paste into lower pane", PLAIN_MESSAGE);
    // Object aux = showInputDialog(null, scrollPane, "Modify the text", PLAIN_MESSAGE, null, null, scrollPane);
    // String text_aux = (String) aux;
    //String text_aux = showInputDialog("Please enter new text", scrollPane);
    // if (text_aux == null) exit(); else
    // public static void showMessageDialog(Component parentComponent, Object message)
    // public static void showMessageDialog(Component parentComponent, Object message, String title, int messageType)
    // public static void showMessageDialog(...) throws HeadlessException
      // Component parentComponent, --- Frame in which the dialog is displayed; if null, or if the parentComponent has no Frame, a default Frame is used
      // Object message, --- the Object to display
      // String title, --- the title string for the dialog
      // int messageType, --- type of message to be displayed: ERROR_MESSAGE, INFORMATION_MESSAGE, WARNING_MESSAGE, QUESTION_MESSAGE, or PLAIN_MESSAGE
      // Icon icon) --- icon to display in the dialog that helps the user identify the kind of message that is being displayed
    if (text_aux == null || "".equals(text_aux))
      showMessageDialog(null, "Empty TEXT Input!", "Alert", WARNING_MESSAGE);
    else if (search_node_text(text_aux)!=-1)
      showMessageDialog(null, "TEXT \"" + text_aux + "\" exists already!!!", "Alert", ERROR_MESSAGE);
    else {
      JTextArea textArea_2 = new JTextArea(text_aux);
      JScrollPane scrollPane_2 = new JScrollPane(textArea_2);  
      textArea_2.setLineWrap(true);  
      textArea_2.setWrapStyleWord(true); 
      scrollPane_2.setPreferredSize(new Dimension(300, 200));
      showMessageDialog(null, scrollPane_2, "Successfully modified", INFORMATION_MESSAGE);
      // showMessageDialog(null, "TEXT \"" + text_aux + "\" successfully modified!", "Successfully modified", INFORMATION_MESSAGE);
      text=text_aux;
      tooltip.text=text;
    }
  }

  void modify_id() {
    String cur_id = id;
    String id_aux = showInputDialog("Please enter new ID", cur_id);
    // if (text_aux == null) exit(); else
    if (id_aux == null || "".equals(id_aux))
      showMessageDialog(null, "Empty ID Input!!!", "Alert", ERROR_MESSAGE);
    else if (search_node_text(id_aux)!=-1)
      showMessageDialog(null, "ID \"" + id_aux + "\" exists already!!!", "Alert", ERROR_MESSAGE);
    else {
      showMessageDialog(null, "ID \"" + id_aux + "\" successfully added!!!", "Info", INFORMATION_MESSAGE);
      id=id_aux;
      if (text.equals("NULL")) {tooltip.text=id; text=id;}
      for (int j=0; j<i_cur_edge; j++) {
        Edge e = (Edge) edges[j];
        if (e.tail_id.equals(cur_id)) {e.tail_id = id;} 
        if (e.head_id.equals(cur_id)) {e.head_id = id;}
      }
    }
  }

  void delete() {
    println("deleting node " + id);
    deleted = true; 
    // deleted_nodes[num_deleted++]=i;
    for (int j=0; j<i_cur_edge; j++) {
      Edge e = (Edge) edges[j];
      if (e.tail_id==id || e.head_id==id) {e.delete();}
    }
  }

  void create_node() {
  }

  // node DRAWING in NAV
  void draw_node_in_nav(String cur_pre_sub) {
    // println("Draw node " + id); // PRINT CHECK: //<>//<>//
    if (cur_pre_sub.equals("cur")) { // draw the current node
      // *** draw node and text
      fill(compute_node_color());
      stroke(edge_color); ellipseMode(CENTER); strokeWeight(1);
      ellipse((left_offset+actual_width/2)/zoom-xo, (top_offset+actual_height/2)/zoom-yo, 
              actual_width/3, actual_width/3);
      fill(text_color);
      flex_write_lines_in_box(text, default_font_name, default_font_aspect_ratio, "CENTER", "CENTER", 
                              x_nav, y_nav, w_nav, h_nav);
      display_image();
    } else // predecessor nodes
    if (cur_pre_sub.equals("pre")) { // draw a predecessor
      // *** draw node and text
      fill(compute_node_color());
      stroke(edge_color); ellipseMode(CENTER); strokeWeight(1);
      ellipse(x_nav, y_nav, diameter_size, diameter_size);
      fill(text_color);
      flex_write_lines_in_box(id, default_font_name, default_font_aspect_ratio, "CENTER", "CENTER", 
                              x_nav, y_nav, w_nav, h_nav);      
    } else // the other nodes
    if (cur_pre_sub.equals("sub")) { // draw a subsequent
      // *** draw node and text
      fill(compute_node_color());
      stroke(edge_color); ellipseMode(CENTER); strokeWeight(1);
      ellipse(x_nav, y_nav, diameter_size, diameter_size);
      fill(text_color);
      flex_write_lines_in_box(id, default_font_name, default_font_aspect_ratio, "CENTER", "CENTER", 
                              x_nav, y_nav, w_nav, h_nav);      
    }
  } // END draw_node

  void compute_pred_subs() { //<>//<>//
    i_cur_predecessor=0; i_cur_subsequent=0;
    for (int i=0; i<i_cur_edge; i++) {
      Edge e = edges[i];
      if (!e.deleted) {
        if (e.head_id.equals(id)) {
          predecessor_node_ids[i_cur_predecessor++]=e.tail_id;
        } else 
        if (e.tail_id.equals(id)) {
          subsequent_node_ids[i_cur_subsequent++]=e.head_id;
        }  
      }
    }
  }
  
  void modify_image(String image_file_path) {
    node_image = loadImage(image_file_path);
    media_type="image";
  }
    
  void display_image() {
    if (media_type.equals("image") && display_b) {
      if (modality.equals("EDT")) {
        // println("QUI");
        imageMode(CENTER); image(node_image, x, y, (node_image.width*diameter_size)/node_image.height, diameter_size); 
      } else
      if (modality.equals("NAV")) {
        imageMode(CENTER); image(node_image, x_nav, y_nav); //, sg_logo.width*2*y_credits/sg_logo.height, 2*y_credits);
      }
    }
  }

  color compute_node_color() {
    color return_color = color(0);
    if (select1) {return_color = select_color;} // 1st selected color
    else {
      // if (node_tags_counter>0) {
        // Tag t = searchTag(node_tags[0]);
        Tag t = searchTag(node_tag);
        if (t!=null) {return_color = t.tag_color; } // tag-based color 
        else {return_color = node_color;} // generic node color
      // } else {return_color = node_color;} // generic node color 
    }
    return return_color;
  }
  
  // node DRAWING in EDT
  void draw_node() {
    // println("--- Draw node " + id); // PRINT CHECK:
    if (!deleted) { 
      // *** possibly draw selection border (if it is the case)
      fill(compute_node_color());
      // *** draw node and text
      stroke(edge_color); ellipseMode(CENTER); strokeWeight(1);
      ellipse(x, y, w, h);
      if (select1 || select2) {fill(select_text_color);} else {fill(text_color);}
      flex_write_lines_in_box(id, default_font_name, default_font_aspect_ratio, "CENTER", "CENTER", x, y, diameter_size, diameter_size);
      display_image();
    } // END not deleted
  } // END draw_node
}

int searchNodeIdIndex(String id) {
  // println(id);
  for (int i=0; i<i_cur_node; i++) {
    if (nodes[i].id.equals(id) && !nodes[i].deleted) {return i;}
  }
  return -1;
}

int search_node_text(String t) {
  // println(t);
  for (int i=0; i<i_cur_node; i++) {
    if (nodes[i].text.equals(t) && !nodes[i].deleted) {return i;}
  }
  return -1;
}
