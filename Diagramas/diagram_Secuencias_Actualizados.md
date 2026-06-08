# Diagrama de clases — Módulo Skyhawk

Basado en el diagrama de clases 

## 1. Cargar la partida, el avión e iniciar el juego
```mermaid
sequenceDiagram
    actor Jugador

    participant AvionSkyhawk
    participant SkyhawkGameController
    participant SkyhawkJugador
    participant SkyhawkEnemigo

    Jugador ->> +AvionSkyhawk : iniciar()

    %% Crea el controlador del juego
    AvionSkyhawk ->> +SkyhawkGameController : SkyhawkGameController()

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
    SkyhawkGameController -->> -AvionSkyhawk : controlador listo
    
    %% RESPUESTA FINAL AL JUGADOR:
    AvionSkyhawk -->> -Jugador : muestra pantalla de juego (render)
```

## 2. Mover el avión (arriba, abajo, izquierda, derecha)

```mermaid
sequenceDiagram
    actor Jugador
    participant AvionSkyhawk
    participant SkyhawkGameController
    participant SkyhawkJugador

    Jugador ->> +AvionSkyhawk : actualizar()

    AvionSkyhawk ->> +SkyhawkGameController : actualizarMovimiento()

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
    SkyhawkGameController -->> -AvionSkyhawk : Movimiento actualizado

    %% RESPUESTA FINAL AL JUGADOR:
    AvionSkyhawk -->> -Jugador : actualiza posición del avión en pantalla
```

## 3. Disparar y matar un enemigo
```mermaid
sequenceDiagram
    actor Jugador

    participant AvionSkyhawk
    participant SkyhawkGameController
    participant SkyhawkJugador
    participant SkyhawkProyectilJugador
    participant SkyhawkEnemigo
    participant SkyhawkRegistroEstadistica

    Jugador ->> +AvionSkyhawk : actualizar()

    AvionSkyhawk ->> +SkyhawkGameController : dispararSkyhawk()

    SkyhawkGameController ->> +SkyhawkJugador : disparar()
    SkyhawkJugador -->> -SkyhawkGameController : Crea instancia de SkyhawkProyectilJugador y agrega a lista balasJugador

    SkyhawkGameController -->> -AvionSkyhawk : proyectil registrado en el juego

    AvionSkyhawk -->> -Jugador : dibuja disparo en pantalla

    loop hasta que el proyectil impacta o sale de pantalla
        AvionSkyhawk ->> +SkyhawkGameController : actualizarMovimiento()

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


        SkyhawkGameController -->> -AvionSkyhawk : juego actualizado
        
        %% Respuesta visual en cada vuelta del loop para avisar al jugador
            AvionSkyhawk -->> Jugador : Muere enemigo y reaparece (+10 pts)
    end
```

## 4. Morir por colisión 
```mermaid
sequenceDiagram
    participant AvionSkyhawk
    participant GameController
    participant Enemigo
    participant Skyhawk

    loop actualización del juego
        AvionSkyhawk ->> +GameController : detectarColisiones()



        GameController ->> +Enemigo : getX()
        Enemigo -->> -GameController : x

        GameController ->> +Enemigo : getY()
        Enemigo -->> -GameController : y

        opt enemigo choca con Skyhawk
        GameController ->> +Skyhawk : colisionaCon(x, y)
        Skyhawk -->> -GameController : true

            GameController -) +Skyhawk : recibirDanio(1)


            GameController ->> +Enemigo : reaparecer()
            Enemigo -->> -GameController : Enemigo reaparece
        end

        GameController -->> -AvionSkyhawk : 
    AvionSkyhawk ->> +GameController : jugadorVivo()
    GameController ->> +Skyhawk : estaVivo()
    Skyhawk -->> -GameController : false
    GameController -->> -AvionSkyhawk : false
end
        AvionSkyhawk ->> AvionSkyhawk : finalizar()
    

```
## 5 Morir por proyectil enemigo
```mermaid
sequenceDiagram
    participant AvionSkyhawk
    participant GameController
    participant Enemigo
    participant ProyectilEnemigo
    participant Skyhawk

    loop actualización del juego
        AvionSkyhawk ->> +GameController : actualizarMovimiento()

        
        GameController ->> +Enemigo : intentoDisparar()
        Enemigo -->> -GameController : true
        

        opt enemigo dispara
            GameController ->> +Enemigo : disparar()
            Enemigo -->> -GameController : ProyectilEnemigo

        end

        GameController ->> +GameController : detectarColisiones()

        GameController ->> +ProyectilEnemigo : getX()
        ProyectilEnemigo -->> -GameController : x

        GameController ->> +ProyectilEnemigo : getY()
        ProyectilEnemigo -->> -GameController : y

        opt proyectil enemigo impacta al Skyhawk
            GameController ->> +Skyhawk : colisionaCon(x, y)
            Skyhawk -->> -GameController : true

            GameController -) +Skyhawk : recibirDanio(1)

            GameController ->> +Skyhawk : estaVivo()
            Skyhawk -->> -GameController : false
        end

        GameController -->> -AvionSkyhawk : Skyhawk muere

    end
AvionSkyhawk ->> +AvionSkyhawk : finalizar()

```








## 6 Estadisticas
```mermaid
sequenceDiagram
    participant AvionSkyhawk
    participant GameController
    participant Registro_Estadistica_Sky
    participant EstadisticasGenerales

    AvionSkyhawk ->> +AvionSkyhawk : finalizar()

    AvionSkyhawk ->> +GameController : getRegistroEstadistica()

    GameController ->> +Registro_Estadistica_Sky : getPuntaje()
    Registro_Estadistica_Sky -->> -GameController : puntaje

    GameController ->> +Registro_Estadistica_Sky : getEnemigosEliminados()
    Registro_Estadistica_Sky -->> -GameController : enemigosEliminados

    GameController ->> +Registro_Estadistica_Sky : getPartidasJugadas()
    Registro_Estadistica_Sky -->> -GameController : partidasJugadas

    GameController ->> +Registro_Estadistica_Sky : getTiempoJugado()
    Registro_Estadistica_Sky -->> -GameController : tiempoJugado

    GameController ->> +Registro_Estadistica_Sky : getSituacionPartida()
    Registro_Estadistica_Sky -->> -GameController : situacionPartida


    GameController ->> +EstadisticasGenerales : crear EstadisticasGenerales
    EstadisticasGenerales -->> -GameController : estadisticasGenerales

    EstadisticasGenerales -->> GameController : registroEstadistica
    GameController -->> AvionSkyhawk : registroEstadistica

    AvionSkyhawk -->> -AvionSkyhawk :

```
