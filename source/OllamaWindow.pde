import http.requests.*;

public class OllamaWindow extends PApplet {
  String responseText = ""; // Variabile per costruire la risposta completa
  String userPrompt = ""; // Variabile per salvare il prompt dell'utente
  boolean isReceiving = false; // Flag per monitorare lo stato della ricezione
  boolean sendRequest = false; // Flag per indicare quando inviare la richiesta
  boolean resetPrompt = false; // Flag per indicare quando resettare il prompt

  public void settings() {
    size(1000, 600);
  }

  public void setup() {
    textSize(18);
  }

  public void draw() {
    background(255);
    fill(0);
    textAlign(LEFT, TOP);
    text("Inserisci la tua domanda per Ollama:", 18, 20);
    text("Risposta di Ollama:", 18, 150);
    
    // Mostra il prompt inserito dall'utente
    fill(50);
    rect(18, 60, 700, 30); // Area di input per il prompt
    fill(255);
    text(userPrompt, 20, 65); // Mostra il testo del prompt
    
    // Disegna il pulsante "Invia"
    fill(0, 122, 255);
    rect(740, 60, 100, 30);
    fill(255);
    text("Invia", 770, 65);
    
    // Disegna il pulsante "Reset"
    fill(255, 0, 0);
    rect(860, 60, 100, 30);
    fill(255);
    text("Reset", 890, 65);
    
    // Mostra la risposta
    fill(0);
    textSize(16);
    text(responseText, 18, 180, width - 40, height - 200); // Mostra la risposta
    
    // Invia la richiesta se il pulsante "Invia" è stato premuto
    if (sendRequest) {
      sendPrompt();
      sendRequest = false;
    }
    
    // Resetta il campo di input se il pulsante "Reset" è stato premuto
    if (resetPrompt) {
      userPrompt = ""; // Resetta il campo di testo
      resetPrompt = false;
    }
  }

  // Funzione per inviare il prompt a Ollama
  void sendPrompt() {
    responseText = ""; // Reset della risposta
    
    PostRequest post = new PostRequest("http://localhost:11434/api/generate");
    post.addHeader("Content-Type", "application/json");
    
    // Crea il JSON con il prompt dell'utente
    String jsonPrompt = "{ " +
      "\"model\": \"llama3.2\"," +
      "\"prompt\": \"" + userPrompt + "\"," +
      "\"max_tokens\": 50," +       // Regola per lunghezza desiderata
      "\"temperature\": 0.7," +
      "\"top_p\": 0.9," +
      "\"frequency_penalty\": 0.5," +
      "\"presence_penalty\": 0.6," +
      "\"stream\": false," +
      "\"stop\": [\"\\n\", \"END\"]" +
    "}";
    
    post.addData(jsonPrompt);
    post.send();
    
    // Parsing della risposta JSON
    String content = post.getContent();
    
    try {
      // Parso il contenuto come JSON usando JSONObject di Processing
      JSONObject json = parseJSONObject(content);
      
      // Estrai solo il campo "response" per mostrare il testo desiderato
      responseText = json.getString("response");
      
    } catch (Exception e) {
      responseText = "Errore durante il parsing della risposta";
    }
  }

  // Funzione per catturare il testo digitato dall'utente
  public void keyTyped() {
    if (key != '\n') {
      userPrompt += key; // Aggiunge il carattere al prompt
    }
  }

  // Funzione per gestire il backspace
  public void keyPressed() {
    if (key == BACKSPACE && userPrompt.length() > 0) {
      userPrompt = userPrompt.substring(0, userPrompt.length() - 1);
    }
  }

  // Funzione per gestire il click del pulsante
  public void mousePressed() {
    // Controlla se il pulsante "Invia" è stato cliccato
    if (mouseX > 740 && mouseX < 840 && mouseY > 60 && mouseY < 90) {
      sendRequest = true;
    }
    
    // Controlla se il pulsante "Reset" è stato cliccato
    if (mouseX > 860 && mouseX < 960 && mouseY > 60 && mouseY < 90) {
      resetPrompt = true; // Attiva il reset del prompt
    }
  }
}
