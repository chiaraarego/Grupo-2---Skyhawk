import processing.core.*;

public class Boton {
  private float x, y, ancho, alto;
  private String texto;
  private boolean seleccionado;

  private static final float PADDING_IZQUIERDA = 10;
  private static final float PADDING_DERECHA   = 10;
  private static final float TEXT_SIZE         = 12;

  public Boton(float x, float y, float ancho, float alto, String texto) {
    this.x = x;
    this.y = y;
    this.ancho = ancho;
    this.alto = alto;
    this.texto = texto;
    this.seleccionado = false;
  }

  public void dibujar(PApplet app) {
    // 1. Dibujar el rectangulo usando SIEMPRE x, y, ancho, alto (mismo origen que estaEncima)
    if (seleccionado) {
      app.stroke(0, 255, 0);
      app.fill(0, 51, 0);
    } else {
      app.stroke(0, 120, 0);
      app.fill(0, 17, 0);
    }
    app.strokeWeight(2);
    app.rect(x, y, ancho, alto, 3);

    // 2. Preparar el texto con prefijo
    String prefijo   = seleccionado ? "> " : "  ";
    String textoFull = prefijo + texto;

    // 3. Calcular el ancho disponible para el texto y recortarlo si es necesario
    app.textSize(TEXT_SIZE);
    float anchoDisponible = ancho - PADDING_IZQUIERDA - PADDING_DERECHA;
    String textoFinal = recortarTexto(app, textoFull, anchoDisponible);

    // 4. Dibujar el texto dentro del rectangulo
    app.fill(255);
    app.textAlign(PApplet.LEFT, PApplet.CENTER);
    app.text(textoFinal, x + PADDING_IZQUIERDA, y + alto / 2);
  }

  /** Recorta el texto agregando "..." si supera el ancho maximo disponible. */
  private String recortarTexto(PApplet app, String txt, float maxAncho) {
    if (app.textWidth(txt) <= maxAncho) return txt;

    // Ir recortando caracteres hasta que entre con "..."
    String puntos = "...";
    int len = txt.length();
    while (len > 0 && app.textWidth(txt.substring(0, len) + puntos) > maxAncho) {
      len--;
    }
    return txt.substring(0, len) + puntos;
  }

  /**
   * Reposiciona el boton. Llamar esto cada vez que la pantalla recalcula
   * posiciones (por ejemplo al volver de un modulo) para mantener
   * el hitbox sincronizado con el dibujo.
   */
  public void setPos(float nx, float ny) {
    this.x = nx;
    this.y = ny;
  }

  /** Actualiza ancho y alto si el layout cambia. */
  public void setTamano(float nAncho, float nAlto) {
    this.ancho = nAncho;
    this.alto  = nAlto;
  }

  /** El hitbox usa exactamente las mismas coordenadas que rect() en dibujar(). */
  public boolean estaEncima(float mx, float my) {
    return mx >= x && mx <= x + ancho && my >= y && my <= y + alto;
  }

  public void setSeleccionado(boolean seleccionado) { this.seleccionado = seleccionado; }
  public boolean isSeleccionado() { return seleccionado; }
  public String getTexto()  { return texto; }
  public void   setTexto(String t) { this.texto = t; }
  public float getX()      { return x; }
  public float getY()      { return y; }
  public float getAncho()  { return ancho; }
  public float getAlto()   { return alto; }
}
