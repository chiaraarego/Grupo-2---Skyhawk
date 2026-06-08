# Diagrama de secuencia simple - fin de partida y estadisticas

```mermaid
sequenceDiagram
    participant HomeJuego
    participant AvionSkyhawk
    participant GameController
    participant Registro as Registro_Estadistica_Sky
    participant Stats as EstadisticasGenerales
    participant Gestor as GestorEstadisticas

    HomeJuego ->> AvionSkyhawk: actualizar(app)
    AvionSkyhawk ->> GameController: jugadorVivo()
    GameController -->> AvionSkyhawk: false

    Note over AvionSkyhawk: Muestra GAME OVER durante 2500 ms

    AvionSkyhawk ->> AvionSkyhawk: finalizar()
    AvionSkyhawk ->> HomeJuego: evento FINALIZADO

    HomeJuego ->> AvionSkyhawk: getEstadisticasGenerales()
    AvionSkyhawk ->> GameController: getRegistroEstadistica()
    GameController -->> AvionSkyhawk: Registro_Estadistica_Sky

    AvionSkyhawk ->> Registro: registrarTiempo(tiempoSeg)
    AvionSkyhawk ->> Registro: getPuntaje()
    AvionSkyhawk ->> Registro: getPartidasJugadas()
    AvionSkyhawk ->> Registro: getEnemigosEliminados()
    AvionSkyhawk ->> Registro: getTiempoJugado()
    AvionSkyhawk ->> Registro: getSituacionPartida()

    AvionSkyhawk ->> Stats: new EstadisticasGenerales(...)
    Stats -->> AvionSkyhawk: stats
    AvionSkyhawk -->> HomeJuego: stats

    HomeJuego ->> Gestor: guardarEstadisticas(stats)
    HomeJuego ->> HomeJuego: volver a seleccion de modulo
```

Resumen:

- `GameController` detecta que el jugador ya no esta vivo.
- `AvionSkyhawk` espera un momento, finaliza el modulo y avisa al lobby.
- `HomeJuego` recibe el evento `FINALIZADO` y le pide las estadisticas al modulo.
- `AvionSkyhawk` lee el `Registro_Estadistica_Sky` y crea el `EstadisticasGenerales`.
- `HomeJuego` manda ese `EstadisticasGenerales` a `GestorEstadisticas` para guardarlo.

Nota: en el codigo, `GameController` no crea `EstadisticasGenerales`; solo guarda y entrega el `Registro_Estadistica_Sky`. La conversion al formato del lobby la hace `AvionSkyhawk`.
