# Diagrama de Secuencia — Módulo Skyhawk

Basado en el diagrama de clases 

## 1. Cargar la partida, el avión e iniciar el juego
```mermaid
sequenceDiagram
    actor Jugador

    participant ModuloSkyhawk
    participant SkyhawkGameController
    participant SkyhawkJugador
    participant SkyhawkEnemigo

    Jugador ->> +ModuloSkyhawk : iniciar()

    %% Crea el controlador del juego
    ModuloSkyhawk ->> +SkyhawkGameController : SkyhawkGameController()

    %% El controlador crea al avión del jugador
    SkyhawkGameController ->> +SkyhawkJugador : SkyhawkJugador(xPos, yPos)
    SkyhawkJugador -->> -SkyhawkGameController : avion creado

    %% El controlador se auto-llama para crear la horda de enemigos
    SkyhawkGameController ->> +SkyhawkGameController : crearEnemigos()

    loop por cada enemigo inicial
        SkyhawkGameController ->> +SkyhawkEnemigo : SkyhawkEnemigo(xPos, yPos)
        SkyhawkEnemigo -->> -SkyhawkGameController : Enemigo creado
    end

    %% Van cerrándose ordenadamente las ejecuciones abiertas de atrás hacia adelante
    SkyhawkGameController -->> -ModuloSkyhawk : controlador listo
    
    %% RESPUESTA FINAL AL JUGADOR:
    ModuloSkyhawk -->> -Jugador : muestra pantalla de juego (render)
```

## 2. Mover el avión (arriba, abajo, izquierda, derecha)

```mermaid
sequenceDiagram
    actor Jugador
    participant ModuloSkyhawk
    participant SkyhawkGameController
    participant SkyhawkJugador

    Jugador ->> ModuloSkyhawk : [presiona tecla]
    ModuloSkyhawk ->> +ModuloSkyhawk : actualizar()

    ModuloSkyhawk ->> +SkyhawkGameController : actualizarMovimiento()

    %% Abre la activación interna para leer el teclado
    SkyhawkGameController ->> +SkyhawkGameController : leerTeclado()

    alt tecla ARRIBA
        SkyhawkGameController ->> +SkyhawkJugador : mover(Direccion.ARRIBA)
        SkyhawkJugador -->> -SkyhawkGameController : Se mueve arriba
    else tecla ABAJO
        SkyhawkGameController ->> +SkyhawkJugador : mover(Direccion.ABAJO)
        SkyhawkJugador -->> -SkyhawkGameController : Se mueve abajo
    else tecla IZQUIERDA
        SkyhawkGameController ->> +SkyhawkJugador : mover(Direccion.IZQUIERDA)
        SkyhawkJugador -->> -SkyhawkGameController : Se mueve izquierda
    else tecla DERECHA
        SkyhawkGameController ->> +SkyhawkJugador : mover(Direccion.DERECHA)
        SkyhawkJugador -->> -SkyhawkGameController : Se mueve derecha
    end

    
    %% Retorna el flujo al objeto principal de la app
    SkyhawkGameController -->> -ModuloSkyhawk : Movimiento actualizado

    %% RESPUESTA FINAL AL JUGADOR:
    ModuloSkyhawk -->> -Jugador : actualiza posición del avión en pantalla
```

## 3. Disparar y matar un enemigo
```mermaid
sequenceDiagram
    actor Jugador

    participant ModuloSkyhawk
    participant SkyhawkGameController
    participant SkyhawkJugador
    participant SkyhawkProyectilJugador
    participant SkyhawkEnemigo
    participant SkyhawkRegistroEstadistica

    Jugador ->> +ModuloSkyhawk : actualizar()

    ModuloSkyhawk ->> +SkyhawkGameController : dispararSkyhawk()

    SkyhawkGameController ->> +SkyhawkJugador : disparar()
    SkyhawkJugador -->> -SkyhawkGameController : Crea instancia de SkyhawkProyectilJugador y agrega a lista balasJugador

    SkyhawkGameController -->> -ModuloSkyhawk : proyectil registrado en el juego

    ModuloSkyhawk -->> -Jugador : dibuja disparo en pantalla

    loop hasta que el proyectil impacta o sale de pantalla
        activate ModuloSkyhawk

        ModuloSkyhawk ->> +SkyhawkGameController : actualizarMovimiento()

        SkyhawkGameController ->> +SkyhawkProyectilJugador : actualizarProyectil()
        SkyhawkProyectilJugador -->> -SkyhawkGameController : Posicion actualizada

        SkyhawkGameController ->> +SkyhawkGameController : detectarColisiones()

        SkyhawkGameController ->> +SkyhawkProyectilJugador : getX()
        SkyhawkProyectilJugador -->> -SkyhawkGameController : x

        SkyhawkGameController ->> +SkyhawkProyectilJugador : getY()
        SkyhawkProyectilJugador -->> -SkyhawkGameController : y

        SkyhawkGameController ->> +SkyhawkEnemigo : colisionaCon(x, y)
        SkyhawkEnemigo -->> -SkyhawkGameController : true

        opt proyectil impacta al enemigo
            SkyhawkGameController -) +SkyhawkEnemigo : recibirDanio(1)
            
            SkyhawkGameController ->> +SkyhawkEnemigo : estaViva()
            SkyhawkEnemigo -->> -SkyhawkGameController : false

            SkyhawkGameController -) +SkyhawkRegistroEstadistica : registrarEnemigoEliminado()
            SkyhawkGameController ->> +SkyhawkEnemigo : reaparecer()
            SkyhawkEnemigo -->> -SkyhawkGameController : Enemigo reaparece
            
        end


        SkyhawkGameController -->> -ModuloSkyhawk : juego actualizado
        
        %% Respuesta visual en cada vuelta del loop para avisar al jugador
            ModuloSkyhawk -->> Jugador : Muere enemigo y reaparece (+10 pts)
        deactivate ModuloSkyhawk
    end
```

## 4. Morir por colisión 
```mermaid
sequenceDiagram
    participant ModuloSkyhawk
    participant SkyhawkGameController
    participant SkyhawkEnemigo
    participant SkyhawkJugador

    

    loop actualización del juego

        ModuloSkyhawk ->> +SkyhawkGameController : detectarColisiones()
       activate ModuloSkyhawk


        SkyhawkGameController ->> +SkyhawkEnemigo : getX()
        SkyhawkEnemigo -->> -SkyhawkGameController : x

        SkyhawkGameController ->> +SkyhawkEnemigo : getY()
        SkyhawkEnemigo -->> -SkyhawkGameController : y

        opt enemigo choca con Skyhawk
        SkyhawkGameController ->> +SkyhawkJugador : colisionaCon(x, y)
        SkyhawkJugador -->> -SkyhawkGameController : true

            SkyhawkGameController -) +SkyhawkJugador : recibirDanio(1)


            SkyhawkGameController ->> +SkyhawkEnemigo : reaparecer()
            SkyhawkEnemigo -->> -SkyhawkGameController : Enemigo reaparece
        end

        SkyhawkGameController -->> -ModuloSkyhawk : 
    ModuloSkyhawk ->> +SkyhawkGameController : jugadorVivo()
    SkyhawkGameController ->> +SkyhawkJugador : estaVivo()
    SkyhawkJugador -->> -SkyhawkGameController : false
    SkyhawkGameController -->> -ModuloSkyhawk : false
end
        ModuloSkyhawk ->> ModuloSkyhawk : finalizar()
    
    deactivate ModuloSkyhawk
```

## 5. Morir por proyectil enemigo
```mermaid
sequenceDiagram
    participant ModuloSkyhawk
    participant SkyhawkGameController
    participant SkyhawkEnemigo
    participant SkyhawkProyectilEnemigo
    participant SkyhawkJugador



    loop actualización del juego
        ModuloSkyhawk ->> +SkyhawkGameController : actualizarMovimiento()
    activate ModuloSkyhawk
        SkyhawkGameController ->> +SkyhawkEnemigo : intentoDisparar()
        SkyhawkEnemigo -->> -SkyhawkGameController : true

        opt enemigo dispara
            SkyhawkGameController ->> +SkyhawkEnemigo : disparar()
            SkyhawkEnemigo -->> -SkyhawkGameController : SkyhawkProyectilEnemigo
        end

        SkyhawkGameController ->> +SkyhawkGameController : detectarColisiones()

        SkyhawkGameController ->> +SkyhawkProyectilEnemigo : getX()
        SkyhawkProyectilEnemigo -->> -SkyhawkGameController : x

        SkyhawkGameController ->> +SkyhawkProyectilEnemigo : getY()
        SkyhawkProyectilEnemigo -->> -SkyhawkGameController : y

        opt proyectil enemigo impacta al Skyhawk
            SkyhawkGameController ->> +SkyhawkJugador : colisionaCon(x, y)
            SkyhawkJugador -->> -SkyhawkGameController : true

            SkyhawkGameController -) +SkyhawkJugador : recibirDanio(1)

            SkyhawkGameController ->> +SkyhawkJugador : estaVivo()
            SkyhawkJugador -->> -SkyhawkGameController : false
        end

        SkyhawkGameController -->> -ModuloSkyhawk : Skyhawk muere
    end

    ModuloSkyhawk ->> ModuloSkyhawk : finalizar()

    deactivate ModuloSkyhawk
```

## 6. Estadisticas 
```mermaid
sequenceDiagram
    participant HomeJuego
    participant ModuloSkyhawk
    participant SkyhawkGameController
    participant Registro as SkyhawkRegistroEstadistica
    participant Stats as EstadisticasGenerales
    participant Gestor as GestorEstadisticas



    HomeJuego ->> ModuloSkyhawk: actualizar(app)
    activate ModuloSkyhawk
    activate HomeJuego
    ModuloSkyhawk ->> SkyhawkGameController: jugadorVivo()
    activate SkyhawkGameController
    SkyhawkGameController -->> ModuloSkyhawk: false
    deactivate SkyhawkGameController

    Note over ModuloSkyhawk: Muestra GAME OVER durante 2500 ms

    ModuloSkyhawk ->> ModuloSkyhawk: finalizar()
    ModuloSkyhawk -->> HomeJuego: evento FINALIZADO
    deactivate ModuloSkyhawk

    HomeJuego ->> HomeJuego: finalizarModuloActual()

    HomeJuego ->> ModuloSkyhawk: getEstadisticasGenerales()
    activate ModuloSkyhawk

    ModuloSkyhawk ->> SkyhawkGameController: getRegistroEstadistica()
    activate SkyhawkGameController
    SkyhawkGameController -->> ModuloSkyhawk: registro
    deactivate SkyhawkGameController

    ModuloSkyhawk -) Registro: registrarTiempo(tiempoSeg)
    activate Registro
    deactivate Registro

    ModuloSkyhawk ->> Registro: getSituacionPartida()
    activate Registro
    Registro -->> ModuloSkyhawk: "DERROTA"
    deactivate Registro

    ModuloSkyhawk ->> Registro: getPuntaje()
    activate Registro
    Registro -->> ModuloSkyhawk: Puntaje
    deactivate Registro

    ModuloSkyhawk ->> Registro: getPartidasJugadas()
    activate Registro
    Registro -->> ModuloSkyhawk: PartidasJugadas
    deactivate Registro

    ModuloSkyhawk ->> Registro: getEnemigosEliminados()
    activate Registro
    Registro -->> ModuloSkyhawk: EnemigosEliminados
    deactivate Registro

    ModuloSkyhawk ->> Registro: getTiempoJugado()
    activate Registro
    Registro -->> ModuloSkyhawk: TiempoJugado
    deactivate Registro

    ModuloSkyhawk ->> Stats: new EstadisticasGenerales(...)
    activate Stats
    Stats -->> ModuloSkyhawk: stats
    deactivate Stats

    ModuloSkyhawk -->> HomeJuego: stats
    deactivate ModuloSkyhawk

    HomeJuego ->> Gestor: guardarEstadisticas(stats)
    activate Gestor
    deactivate Gestor
    deactivate HomeJuego
```
