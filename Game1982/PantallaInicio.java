import processing.core.*;

public class PantallaInicio {
  private PImage fondoHome;
  private Boton botonStart;

  public PantallaInicio(PApplet app, int anchoVentana, int altoVentana) {
    fondoHome = app.loadImage("assets/background/fondo_home.png");

    float bAncho = 280;
    float bAlto = 50;
    botonStart = new Boton(anchoVentana / 2f - bAncho / 2f, altoVentana * 0.65f, bAncho, bAlto, "PRESS START");
    botonStart.setSeleccionado(true);
  }

  public void dibujar(PApplet app) {
    if (fondoHome != null) {
      app.image(fondoHome, 0, 0, app.width, app.height);
    } else {
      app.background(0);
    }

    // título principal
    app.textSize(72);
    app.textAlign(PApplet.CENTER, PApplet.CENTER);
    dibujarTextoConBorde(app, "1982", app.width / 2f, app.height * 0.22f, 3);

    app.textSize(24);
    dibujarTextoConBorde(app, "GUERRA DE MALVINAS", app.width / 2f, app.height * 0.33f, 2);

    // línea decorativa
    app.stroke(0, 120, 0);
    app.strokeWeight(1);
    app.line(50, app.height * 0.40f, app.width - 50, app.height * 0.40f);

    app.textSize(15);
    dibujarTextoConBorde(app, "UN SHOOTER AEREO DEL CONFLICTO DEL ATLANTICO SUR", app.width / 2f, app.height * 0.48f, 2);

    botonStart.dibujar(app);
  }

  private void dibujarTextoConBorde(PApplet app, String texto, float x, float y, int borde) {
    app.fill(0);
    for (int dx = -borde; dx <= borde; dx++) {
      for (int dy = -borde; dy <= borde; dy++) {
        if (dx != 0 || dy != 0) {
          app.text(texto, x + dx, y + dy);
        }
      }
    }

    app.fill(255);
    app.text(texto, x, y);
  }

  public boolean clicEnStart(float mx, float my) {
    return botonStart.estaEncima(mx, my);
  }
}
