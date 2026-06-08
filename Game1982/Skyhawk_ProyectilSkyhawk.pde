// La bala que dispara el avion del jugador: sube por la pantalla.
class SkyhawkProyectilJugador extends SkyhawkProyectil
{
  SkyhawkProyectilJugador(int xPos, int yPos)
  {
    super(xPos, yPos);
  }

  void actualizarProyectil()
  {
    this.y = this.y - this.velocidad;   // sube
  }

  void dibujar()
  {
    fill(255, 0, 0);              // amarillo
    rect(this.x, this.y, 4, 12);    // balita finita y vertical
  }
}
