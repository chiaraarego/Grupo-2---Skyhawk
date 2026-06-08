// La bala que disparan los enemigos: baja por la pantalla.
// La crea el SkyhawkGameController cuando un enemigo decide disparar (SkyhawkEnemigo.intentaDisparar()).
class SkyhawkProyectilEnemigo extends SkyhawkProyectil
{
  SkyhawkProyectilEnemigo(int xPos, int yPos)
  {
    super(xPos, yPos);
  }

  void actualizarProyectil()
  {
    this.y = this.y + this.velocidad;   // baja
  }

  void dibujar()
  {
    fill(255, 140, 0);              // naranja
    rect(this.x, this.y, 4, 12);
  }
}
