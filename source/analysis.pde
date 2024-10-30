PrintWriter storyprint; // file that contains the story print

void headerStoryCountAndPrint() {
  storyprint = createWriter("data/storyprints/"+graph_name+"_storyprint.txt");
  storyprint.println("STORYGRAPHIA STORY PRINT"); // header 
  storyprint.println("===================================================== \n"); 
  String[] unit_id_list = new String[totalNum]; for (int i=0; i<unit_id_list.length; i++) {unit_id_list[i]="NULL";}
  int unit_id_list_counter = 0;
  int num_stories = storyCountAndPrint("", unit_id_list, unit_id_list_counter, "", -1, 0); // empty story, empty unit id concatenation, no last unit, 0 stories
  storyprint.println("===================================================== \n"); 
  String propp_used="NO Propp functions"; 
  String precond_eff_used="NO logic constraints"; 
  String arc_used="NO tension arc";
  float ratio = (float) num_stories / i_cur_node; // computing ratio
  for (int i=0; i<i_cur_node; i++) { // checking constraints used
    Unit u = (Unit) nodes[i];
    if (u.unit_propp_tag_index!=-1) {propp_used="Propp functions";}
    if (u.unit_effects_counter!=0) {precond_eff_used="Logic constraints";}
    if (!u.unit_tension_name.equals("NULL")) {arc_used="Tension arc";}
  }
  storyprint.println(" STORYGRAPHIA STATISTICS, " + graph_name); 
  storyprint.println(i_cur_node + " units, " + i_cur_tag + " tags " + i_cur_agent + " agents "); 
  storyprint.println(propp_used + ", " + precond_eff_used + ", " + arc_used); 
  storyprint.println(num_stories + " potential linear stories, ratio " + ratio); 
  storyprint.println(" in plot generation mode: " + plot_generation_mode); 
  storyprint.flush();
}

String unitType(Unit u) { // returns one of {"START", "MIDDLE", "END", "NULL"}
  String unit_type = "NULL"; 
  boolean head_b = false; boolean tail_b = false; // default: isolated "NULL" unit 
  for (int i=0; i<i_cur_edge;i++) {if (edges[i].head_id==u.id) {head_b = true;}} // is unit head of at least one edge?
  for (int i=0; i<i_cur_edge;i++) {if (edges[i].tail_id==u.id) {tail_b = true;}} // is unit tail of at least one edge?
  if (head_b && tail_b) {unit_type = "MIDDLE";} else 
  if (head_b) {unit_type = "END";} else
  if (tail_b) {unit_type = "START";}
  return unit_type;
}

int storyCountAndPrint(String preStory, String[] _unit_id_list, int _unit_id_list_counter, String unit_id_concatenation, int lastUnitIndex, int preCount) { 
  String story = preStory; int count = preCount; boolean loop = false;
  String[] uil = _unit_id_list; int uilc = _unit_id_list_counter; String cur_unit_id_concatenation = unit_id_concatenation;
  // for each node
  for (int i=0; i<i_cur_node; i++) {
    Unit u = (Unit) nodes[i];
    if (story.equals("")) {// if story is empty string 
      if (unitType(u).equals("START") && lastUnitIndex==-1) { // if unit type == START and no previous unit
        String new_story = story + "\n" + u.text; // set story to unit text and call this function recursively
        // int ret = storyCountAndPrint(new_story, list+str(i), i, count);
        uil[uilc] = u.id; uilc++;
        int ret = storyCountAndPrint(new_story, uil, uilc, cur_unit_id_concatenation+u.id, i, count);
        if (ret==-1) {println("ERROR IN START STORY UNIT CHAINING!"); return -1;} else {count = ret;}
      } // END if correct START
    } else { // else (story is not empty)
      int edge_index = search_edge_head_tail_index(i,lastUnitIndex, plot_generation_mode);
      if (edge_index!=-1) {// if lastUnit is a previous unit of the current one  
        String new_story = story + "\n-\n--> " + edges[edge_index].label + "\n-\n" + u.text; // add unit text to story 
        if (searchStringIndex(u.id, uil, 0, uilc-1)!=-1) {loop = true;}
        if (unitType(u).equals("END") || loop) { // if unit type = END 
          // increment count and print story in the output file; then exit
          count++;
          // storyprint.write("\n" + count + ": " + list+"-"+str(i) + "\n" + new_story + "\n+++++++++++++++++");
          if (loop) {
            storyprint.write("\n" + count + ": " + cur_unit_id_concatenation+"-"+u.id + "(LOOP) \n" + new_story + "\n\n+++++++++++++++++++++++++++++++++");
          } else {
            storyprint.write("\n" + count + ": " + cur_unit_id_concatenation+"-"+u.id + "\n" + new_story + "\n\n+++++++++++++++++++++++++++++++++");
          }
          storyprint.write("\n+++++++++++++++++++++++++++++++++\n+++++++++++++++++++++++++++++++++\n");
          // println(count + " " + new_story);
          //return count;
        } else {// else 
          if (unitType(u).equals("MIDDLE") && !loop) { // if unit type = MIDDLE
            // int ret = storyCountAndPrint(new_story, list+str(i), i, count); // call this function recursively
            uil[uilc] = u.id; uilc++;
            int ret = storyCountAndPrint(new_story, uil, uilc, cur_unit_id_concatenation+"-"+u.id, i, count); // call this function recursively
            if (ret==-1) {println("ERROR IN CONTINUING STORY UNIT CHAINING!"); return -1;} // if error, return -1
            else {count = ret;}
          }
        }
      }
    }
  }
  storyprint.flush();
  return count;
}
