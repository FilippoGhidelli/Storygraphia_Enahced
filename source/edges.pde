// GRAPH EDGES
Edge[] edges; // edges in manual, arc, and Propp modes 
String[] edge_creation_modes = {"CONDITIONAL","NON_CONDITIONAL"}; // CURRENTLY NOT USED 
int total_num_edges; 
int i_cur_edge=0; 
int i_cur_painting_edge=0; int i_cur_sculpting_edge=0;
int edge_counter = 0; // = num*2; // numero di archi
color edge_color;

class Edge {
  String head_id, tail_id; 
  String id; // edge identifier
  String label;
  float label_x, label_y;
  float label_x_nav, label_y_nav;
  boolean select, deleted;
  String[] pg_modes; // creation mode: MANUAL, PAINTING, SCULPTING, TENSION, PROPP
  int pg_mode_counter;
  ToolTip tooltip;

  Edge(String head_id_aux, String tail_id_aux, String id_aux, String label_aux, String _pg_mode) {
    head_id = head_id_aux; tail_id = tail_id_aux; id = id_aux; label = label_aux; select=false; deleted=false; 
    pg_modes = new String[5]; for (int i=0; i<pg_modes.length; i++) {pg_modes[i]="NULL";} pg_mode_counter=0;
    if (!_pg_mode.equals("NULL")) {pg_modes[0] = _pg_mode; pg_mode_counter=1; // it is NULL when reading from file
      if (pg_modes[0].equals("MANUAL") || pg_modes[0].equals("PROPP") || pg_modes[0].equals("TENSION")) { // cannot be NULL can occur when loading story file
        pg_modes[0] = "MANUAL"; pg_modes[1] = "TENSION"; pg_modes[2] = "PROPP"; pg_mode_counter=3;
      }
    }
    label_coordinates(); 
    tooltip = new ToolTip(label, label_x, label_y-diameter_size, actual_width/2, actual_height/2, default_font_name, default_font_size, default_font_aspect_ratio);  
    // tooltip = new ToolTip(label, size_x/2, size_y/2, size_x/2, size_y/2, default_font_name, default_font_size, default_font_aspect_ratio);  
  }
  
  void delete() {
    // println("deleting edge " + id);
    deleted=true;
  }

  boolean is_pg_mode_edge(String pg_mode) {
    if (searchStringIndex(pg_mode, pg_modes, 0, pg_modes.length)==-1) return false;
    else return true;
  }

  void add_mode(String pg_mode) {
    if (!is_pg_mode_edge(pg_mode)) {
      pg_modes[pg_mode_counter] = pg_mode; pg_mode_counter++;
    }
  }

  void modify_label() {
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
    JTextArea textArea = new JTextArea(label);
    JScrollPane scrollPane = new JScrollPane(textArea);  
    textArea.setLineWrap(true);  
    textArea.setWrapStyleWord(true); 
    scrollPane.setPreferredSize(new Dimension(300, 200));
    String label_aux = showInputDialog(null, scrollPane, "Modify and paste into lower pane", PLAIN_MESSAGE);
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
    if (label_aux == null || "".equals(label_aux))
      showMessageDialog(null, "Empty TEXT Input!", "Alert", WARNING_MESSAGE);
    else if (search_node_text(label_aux)!=-1)
      showMessageDialog(null, "TEXT \"" + label_aux + "\" exists already!!!", "Alert", ERROR_MESSAGE);
    else {
      JTextArea textArea_2 = new JTextArea(label_aux);
      JScrollPane scrollPane_2 = new JScrollPane(textArea_2);  
      textArea_2.setLineWrap(true);  
      textArea_2.setWrapStyleWord(true); 
      scrollPane_2.setPreferredSize(new Dimension(300, 200));
      showMessageDialog(null, scrollPane_2, "Successfully modified", INFORMATION_MESSAGE);
      // showMessageDialog(null, "TEXT \"" + text_aux + "\" successfully modified!", "Successfully modified", INFORMATION_MESSAGE);
      label=label_aux;
      tooltip.text=label;
    }
  }
    
  void modify_id() {
    String cur_id = id;
    String id_aux = showInputDialog("Please enter new ID, currently " + cur_id);
    if (id_aux == null || id_aux.equals(""))
      showMessageDialog(null, "Empty ID Input!!!", "Alert", ERROR_MESSAGE);
    else if (search_edge_label_index(id_aux, plot_generation_mode)!=-1) {
      showMessageDialog(null, "WARNING: ID \"" + id_aux + "\" exists already!!!", "Alert", ERROR_MESSAGE);
      id=id_aux; tooltip.text=id; label=id;
    } else {
      showMessageDialog(null, "ID \"" + id_aux + "\" successfully added!!!", "Info", INFORMATION_MESSAGE);
      id=id_aux; if (label.equals("NULL")) {tooltip.text=id; label=id;}
    }
  }

  void draw_labelled_edge() { 
    if (!deleted) {
      int head_index = searchNodeIdIndex(head_id); int tail_index = searchNodeIdIndex(tail_id);
      Node head = nodes[head_index]; Node tail = nodes[tail_index];
      fill(edge_color); stroke(edge_color); strokeWeight(1);// grey filling
      label_coordinates(); 
      if (modality.equals("EDT")) {
        drawExternalLine(tail.x, tail.y, label_x, label_y, diameter_size/2);
        drawExternalArrow(label_x, label_y, head.x, head.y, diameter_size/2);
      } else 
      if (modality.equals("NAV")) {
        Unit u = (Unit) nodes[cur_nav_node_index];
        if (u.id.equals(head.id)) {
          drawExternalLine(tail.x_nav, tail.y_nav, label_x_nav, label_y_nav, diameter_size/2);
          drawExternalArrowDiff(label_x_nav, label_y_nav, head.x_nav, head.y_nav, diameter_size/2, head.w_nav/2);}
        else if (u.id.equals(tail.id)) {
          drawExternalLine(tail.x_nav, tail.y_nav, label_x_nav, label_y_nav, diameter_size/2);
          drawExternalArrowDiff(label_x_nav, label_y_nav, head.x_nav, head.y_nav, head.w_nav/2, diameter_size/2);
        }
      } 
      if (modality.equals("EDT") && select) {fill(select_color); noStroke(); ellipse(label_x, label_y, diameter_size, diameter_size);}
      // *** draw label
      fill(text_color);
      if (modality.equals("EDT")) {
        flex_write_lines_in_box(id, default_font_name, default_font_aspect_ratio, "CENTER", "CENTER", label_x, label_y, diameter_size, diameter_size);
      } else 
      if (modality.equals("NAV")) {
        flex_write_lines_in_box(id, default_font_name, default_font_aspect_ratio, "CENTER", "CENTER", label_x_nav, label_y_nav, diameter_size, diameter_size);
      }  
    }
  }
  
  void label_coordinates() {
    int head_index = searchNodeIdIndex(head_id); int tail_index = searchNodeIdIndex(tail_id);
    Node head = nodes[head_index]; Node tail = nodes[tail_index];
    if (modality.equals("EDT")) {
      label_x = (tail.x + head.x) / 2;
      label_y = (tail.y + head.y) / 2;
    } else  
    if (modality.equals("NAV")) {
      float angle = atan2(tail.y_nav - head.y_nav, tail.x_nav - head.x_nav);
      label_x_nav = ((tail.x_nav - tail.w_nav*cos(angle)) + (head.x_nav+head.w_nav*cos(angle))) / 2;
      label_y_nav = ((tail.y_nav - tail.h_nav*sin(angle)) + (head.y_nav+head.h_nav*sin(angle))) / 2;
    }   
  }

}

// draw all possible edges (depending on plot generation mode
void draw_labelled_edges() {
  if (plot_generation_mode.equals("PAINTING")) { 
    for (int i=0; i<i_cur_edge; i++) {
      if (searchStringIndex("PAINTING", edges[i].pg_modes, 0, edges[i].pg_modes.length)!=-1) {// if modes contain PAINTING
        edges[i].draw_labelled_edge();}
    }
  } else if (plot_generation_mode.equals("SCULPTING")) {
    for (int i=0; i<i_cur_edge; i++) {
      if (searchStringIndex("SCULPTING", edges[i].pg_modes, 0, edges[i].pg_modes.length)!=-1) {// if modes contain SCULPTING
        edges[i].draw_labelled_edge();}
    } 
  } else { // MANUAL, TENSION, OR PROPP MODE
    for (int i=0; i<i_cur_edge; i++) {
      if (searchStringIndex("MANUAL", edges[i].pg_modes, 0, edges[i].pg_modes.length)!=-1 || 
          searchStringIndex("TENSION", edges[i].pg_modes, 0, edges[i].pg_modes.length)!=-1 || 
          searchStringIndex("PROPP", edges[i].pg_modes, 0, edges[i].pg_modes.length)!=-1) {edges[i].draw_labelled_edge();}
    } 
  }
}

// create new identifier for tag label on button
String create_edge_id() { // creates id's (e+number) for edges
  boolean id_ok = false; 
  int increment = 0; String id_aux = "e" + str(i_cur_edge + increment); 
  while (!id_ok) {
    if (search_edge_id_index(id_aux, plot_generation_mode)==-1) {return id_aux;}
    else {increment++;}
  }
  return "NULL";
}

void create_edge(String head_node_id, String tail_node_id, String _label) {
  int head_index = searchNodeIdIndex(head_node_id); int tail_index = searchNodeIdIndex(tail_node_id); 
  int index = search_edge_head_tail_index(head_index, tail_index, plot_generation_mode); // find the edge index
  if (index!=-1) { // if the edge already exists
    replaceString(plot_generation_mode, "NULL", edges[index].pg_modes, 0, edges[index].pg_modes.length); edges[index].pg_mode_counter++;}
  else {
    String aux_id = create_edge_id();
    edges[i_cur_edge]=new Edge(head_node_id, tail_node_id, aux_id, _label, plot_generation_mode); // create edge
    i_cur_edge++; // increment edge counter
  }
}

int search_edge_id_index(String id, String pg_mode) {
  // println(id);
  for (int i=0; i<i_cur_edge; i++) {
    if (edges[i].id.equals(id) && !edges[i].deleted && searchStringIndex(pg_mode, edges[i].pg_modes, 0, edges[i].pg_modes.length)!=-1) {return i;}
  }
  return -1;
}

int search_edge_label_index(String l, String pg_mode) {
  // println(t);
  for (int i=0; i<i_cur_edge; i++) {
    if (edges[i].label.equals(l) && !edges[i].deleted && searchStringIndex(pg_mode, edges[i].pg_modes, 0, edges[i].pg_modes.length)!=-1) {return i;}
  }
  return -1;
}

// search edge index in some pg_mode (if "NULL", any mode)
int search_edge_head_tail_index(int unitHeadIndex, int unitTailIndex, String pg_mode) {
  Unit head = (Unit) nodes[unitHeadIndex]; Unit tail = (Unit) nodes[unitTailIndex];
  if (pg_mode.equals("NULL")) {
    for (int i=0; i<i_cur_edge; i++) {
      if (edges[i].head_id.equals(head.id) && 
          edges[i].tail_id.equals(tail.id) && 
          !edges[i].deleted) {return i;}
    }
  } else {    
    for (int i=0; i<i_cur_edge; i++) {
      if (edges[i].head_id.equals(head.id) && 
          edges[i].tail_id.equals(tail.id) && 
          !edges[i].deleted && 
          searchStringIndex(pg_mode, edges[i].pg_modes, 0, edges[i].pg_modes.length)!=-1) {return i;}
    }
  }
  return -1;
}
