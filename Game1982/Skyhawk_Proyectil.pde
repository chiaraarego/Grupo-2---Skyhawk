// Clase base de las balas. Guarda la posicion y la velocidad.
// Las subclases (SkyhawkProyectilJugador, SkyhawkProyectilEnemigo) dicen para donde se mueve
// cada una y de que color se dibuja.
class SkyhawkProyectil
{
  protected int x;
  protected int y;
  protected int velocidad;

  SkyhawkProyectil(int xPos, int yPos)
  {
    this.x = xPos;
    this.y = yPos;
    this.velocidad = 8;
  }

  // Las subclases sobrescriben estos metodos.
  void actualizarProyectil()
  {
  }

  void dibujar()
  {
  }

  // Getters (encapsulamiento): la posicion se lee desde afuera solo por aca.
  public int getX() { return this.x; }
  public int getY() { return this.y; }
}
