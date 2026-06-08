// Skyhawk_Registro_Estadistica_Sky.pde
// Registra las estadisticas de UNA partida de Skyhawk mientras se juega.
// SkyhawkGameController lo crea y lo va actualizando; ModuloSkyhawk lo lee al finalizar
// para construir el EstadisticasGenerales que entiende el lobby.
class SkyhawkRegistroEstadistica {

  private int puntaje;
  private int enemigosEliminados;
  private int partidasJugadas;
  private long tiempoJugado;          // en segundos
  private String situacionPartida;    // "DERROTA" / "VICTORIA"

  SkyhawkRegistroEstadistica() {
    puntaje = 0;
    enemigosEliminados = 0;
    partidasJugadas = 1;              // este registro representa una partida
    tiempoJugado = 0;
    situacionPartida = "DERROTA";     // survival: la partida siempre termina en derrota
  }

  // ---- registro DURANTE la partida (lo llama SkyhawkGameController) ----
  void registrarEnemigoEliminado(int puntos) {
    puntaje += puntos;
    enemigosEliminados++;
  }

  // ---- registro AL FINALIZAR (lo llama ModuloSkyhawk) ----
  void registrarTiempo(long segundos) {
    tiempoJugado = segundos;
  }

  // ---- getters (los lee ModuloSkyhawk al armar EstadisticasGenerales) ----
  int getPuntaje()             { return puntaje; }
  int getEnemigosEliminados()  { return enemigosEliminados; }
  int getPartidasJugadas()     { return partidasJugadas; }
  long getTiempoJugado()       { return tiempoJugado; }
  String getSituacionPartida() { return situacionPartida; }
}
