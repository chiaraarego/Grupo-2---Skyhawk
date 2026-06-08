class SkyhawkGameController
{
  private SkyhawkJugador skyhawk;                          // el avion del jugador
  private ArrayList<SkyhawkEnemigo> enemigos;              // los aviones enemigos que caen
  private ArrayList<SkyhawkProyectilJugador> balasJugador; // las balas que dispara el avion
  private ArrayList<SkyhawkProyectilEnemigo> balasEnemigo; // las balas que disparan los enemigos
  private SkyhawkRegistroEstadistica registroEstadistica; // recolecta las stats de la partida

  SkyhawkGameController()
  {
    // "Cargar la partida": estado inicial
    registroEstadistica = new SkyhawkRegistroEstadistica();
    // "Cargar el avion": centrado, en la parte de abajo
    skyhawk = new SkyhawkJugador(width / 2, height - 80);
    // "Cargar los enemigos": una lista de aviones que caen desde arriba
    enemigos = new ArrayList<SkyhawkEnemigo>();
    crearEnemigos();
    // Las balas arrancan vacias
    balasJugador = new ArrayList<SkyhawkProyectilJugador>();
    balasEnemigo = new ArrayList<SkyhawkProyectilEnemigo>();
  }

  // Crea varios enemigos repartidos arriba de la pantalla.
  void crearEnemigos()
  {
    for (int i = 0; i < 5; i++)
    {
      int x = 100 + i * 100;   // separados: 100, 200, 300, 400, 500
      int y = -i * 120;        // escalonados arriba (negativo = todavia afuera)
      enemigos.add(new SkyhawkEnemigo(x, y));
    }
  }

  // Le pide la bala al avion (el avion sabe desde donde sale) y la guarda
  // en la lista de balas del jugador.
  void dispararSkyhawk()
  {
    balasJugador.add(skyhawk.disparar());
  }

  // Devuelve true si el avion del jugador sigue vivo (lo usa el game over).
  boolean jugadorVivo()
  {
    return skyhawk.estaViva();
  }

  void actualizarMovimiento()
  {
    leerTeclado();        // mover el avion segun las teclas apretadas
    skyhawk.actualizar();

    // Mover los enemigos (todos bajan) y, de vez en cuando, hacerlos disparar.
    for (SkyhawkEnemigo e : enemigos)
    {
      e.actualizar();
      if (e.intentaDisparar())
      {
        // El enemigo arma su propia bala (sabe desde donde sale); aca solo la guardamos.
        balasEnemigo.add(e.disparar());
      }
    }

    // Mover las balas del jugador
    for (SkyhawkProyectilJugador bala : balasJugador)
    {
      bala.actualizarProyectil();
    }

    // Mover las balas de los enemigos
    for (SkyhawkProyectilEnemigo bala : balasEnemigo)
    {
      bala.actualizarProyectil();
    }

    detectarColisiones();
  }

  // Revisa los choques: balas del jugador contra enemigos, y enemigos contra el avion.
  void detectarColisiones()
  {
    // 1) Balas del jugador contra enemigos
    ArrayList<SkyhawkProyectilJugador> balasQueSiguen = new ArrayList<SkyhawkProyectilJugador>();
    for (SkyhawkProyectilJugador bala : balasJugador)
    {
      boolean golpeo = false;
      for (SkyhawkEnemigo e : enemigos)
      {
        if (e.colisionaCon(bala.getX(), bala.getY()))
        {
          e.recibirDanio(1);
          golpeo = true;
          if (!e.estaViva())   // si se quedo sin vida, lo derribamos
          {
            registroEstadistica.registrarEnemigoEliminado(10);
            e.reaparecer();    // aparece uno nuevo arriba
          }
        }
      }
      // La bala se queda solo si no golpeo a nadie y sigue dentro de la pantalla.
      if (!golpeo && bala.getY() >= 0)
      {
        balasQueSiguen.add(bala);
      }
    }
    balasJugador = balasQueSiguen;

    // 2) Enemigos contra el avion (choque)
    for (SkyhawkEnemigo e : enemigos)
    {
      if (skyhawk.colisionaCon(e.getX(), e.getY()))
      {
        skyhawk.recibirDanio(1);
        e.reaparecer();   // el enemigo que choco desaparece (aparece uno nuevo)
      }
    }

    // 3) Balas de los enemigos contra el avion del jugador
    ArrayList<SkyhawkProyectilEnemigo> balasEnemQueSiguen = new ArrayList<SkyhawkProyectilEnemigo>();
    for (SkyhawkProyectilEnemigo bala : balasEnemigo)
    {
      boolean golpeo = false;
      if (skyhawk.colisionaCon(bala.getX(), bala.getY()))
      {
        skyhawk.recibirDanio(1);
        golpeo = true;
      }
      // La bala se queda solo si no golpeo al avion y sigue dentro de la pantalla.
      if (!golpeo && bala.getY() <= height)
      {
        balasEnemQueSiguen.add(bala);
      }
    }
    balasEnemigo = balasEnemQueSiguen;
  }

  // Mira que tecla esta apretada y mueve el avion en esa direccion.
  // Se aceptan tanto WASD como las flechas del teclado.
  void leerTeclado()
  {
    if (keyPressed)
    {
      // Teclas W A S D (letras normales)
      if (key == 'w')
      {
        skyhawk.mover(SkyhawkDireccion.ARRIBA);
      }
      if (key == 's')
      {
        skyhawk.mover(SkyhawkDireccion.ABAJO);
      }
      if (key == 'a')
      {
        skyhawk.mover(SkyhawkDireccion.IZQUIERDA);
      }
      if (key == 'd')
      {
        skyhawk.mover(SkyhawkDireccion.DERECHA);
      }

      // Flechas: son teclas "especiales". Processing avisa poniendo
      // key == CODED, y dice cual fue en la variable keyCode.
      if (key == CODED)
      {
        if (keyCode == UP)
        {
          skyhawk.mover(SkyhawkDireccion.ARRIBA);
        }
        if (keyCode == DOWN)
        {
          skyhawk.mover(SkyhawkDireccion.ABAJO);
        }
        if (keyCode == LEFT)
        {
          skyhawk.mover(SkyhawkDireccion.IZQUIERDA);
        }
        if (keyCode == RIGHT)
        {
          skyhawk.mover(SkyhawkDireccion.DERECHA);
        }
      }
    }
  }

  void dibujar()
  {
    skyhawk.dibujar();
    // Dibujar cada enemigo
    for (SkyhawkEnemigo e : enemigos)
    {
      e.dibujar();
    }
    // Dibujar cada bala del jugador
    for (SkyhawkProyectilJugador bala : balasJugador)
    {
      bala.dibujar();
    }
    // Dibujar cada bala de los enemigos
    for (SkyhawkProyectilEnemigo bala : balasEnemigo)
    {
      bala.dibujar();
    }
    // HUD: puntaje y vida
    fill(255);
    textAlign(LEFT, TOP);
    textSize(16);
    text("Puntaje: " + registroEstadistica.getPuntaje(), 10, 10);
    text("Vida: " + skyhawk.getVida(), 10, 30);
  }

  // Getter (encapsulamiento): el adaptador ModuloSkyhawk arma las estadisticas
  // leyendo el registro de la partida a traves de este metodo.
  public SkyhawkRegistroEstadistica getRegistroEstadistica() { return this.registroEstadistica; }
}
