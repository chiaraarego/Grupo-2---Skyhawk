# Diagrama de clases — Módulo Skyhawk

Basado en el diagrama de clases 

## 1. Cargar la partida, el avión e iniciar el juego
```mermaid
sequenceDiagram
    actor Jugador

    participant AvionSkyhawk
    participant GameController
    participant Skyhawk
    participant Enemigo

    Jugador ->> +AvionSkyhawk : iniciar()

    %% Crea el controlador del juego
    AvionSkyhawk ->> +GameController : GameController()

    %% El controlador crea al avión del jugador
    GameController ->> +Skyhawk : Skyhawk(xPos, yPos)
    Skyhawk -->> -GameController : avion creado

    %% El controlador se auto-llama para crear la horda de enemigos
    GameController ->> +GameController : crearEnemigos()

    loop por cada enemigo inicial
        GameController ->> +Enemigo : Enemigo(xPos, yPos)
        Enemigo -->> -GameController : Enemigo creado
    end

    %% Van cerrándose ordenadamente las ejecuciones abiertas de atrás hacia adelante
    GameController -->> -AvionSkyhawk : controlador listo
    
    %% RESPUESTA FINAL AL JUGADOR:
    AvionSkyhawk -->> -Jugador : muestra pantalla de juego (render)
```

## 2. Mover el avión (arriba, abajo, izquierda, derecha)

```mermaid
sequenceDiagram
    actor Jugador
    participant AvionSkyhawk
    participant GameController
    participant Skyhawk

    Jugador ->> +AvionSkyhawk : actualizar()

    AvionSkyhawk ->> +GameController : actualizarMovimiento()

    %% Abre la activación interna para leer el teclado
    GameController ->> +GameController : leerTeclado()

    alt tecla ARRIBA
        GameController ->> +Skyhawk : mover(Direccion.ARRIBA)
        Skyhawk -->> -GameController : Se mueve arriba
    else tecla ABAJO
        GameController ->> +Skyhawk : mover(Direccion.ABAJO)
        Skyhawk -->> -GameController : Se mueve abajo
    else tecla IZQUIERDA
        GameController ->> +Skyhawk : mover(Direccion.IZQUIERDA)
        Skyhawk -->> -GameController : Se mueve izquierda
    else tecla DERECHA
        GameController ->> +Skyhawk : mover(Direccion.DERECHA)
        Skyhawk -->> -GameController : Se mueve derecha
    end

    
    %% Retorna el flujo al objeto principal de la app
    GameController -->> -AvionSkyhawk : Movimiento actualizado

    %% RESPUESTA FINAL AL JUGADOR:
    AvionSkyhawk -->> -Jugador : actualiza posición del avión en pantalla
```

## 3. Disparar y matar un enemigo
```mermaid
sequenceDiagram
    actor Jugador

    participant AvionSkyhawk
    participant GameController
    participant Skyhawk
    participant ProyectilSkyhawk
    participant Enemigo
    participant Registro_Estadistica_Sky

    Jugador ->> +AvionSkyhawk : actualizar()

    AvionSkyhawk ->> +GameController : dispararSkyhawk()

    GameController ->> +Skyhawk : disparar()
    Skyhawk -->> -GameController : Crea instancia de ProyectilSkyhawk y agrega a lista balasJugador

    GameController -->> -AvionSkyhawk : proyectil registrado en el juego

    AvionSkyhawk -->> -Jugador : dibuja disparo en pantalla

    loop hasta que el proyectil impacta o sale de pantalla
        AvionSkyhawk ->> +GameController : actualizarMovimiento()

        GameController ->> +ProyectilSkyhawk : actualizarProyectil()
        ProyectilSkyhawk -->> -GameController : Posicion actualizada

        GameController ->> +GameController : detectarColisiones()

        GameController ->> +ProyectilSkyhawk : getX()
        ProyectilSkyhawk -->> -GameController : x

        GameController ->> +ProyectilSkyhawk : getY()
        ProyectilSkyhawk -->> -GameController : y

        GameController ->> +Enemigo : colisionaCon(x, y)
        Enemigo -->> -GameController : true

        opt proyectil impacta al enemigo
            GameController -) +Enemigo : recibirDanio(1)
            
            GameController ->> +Enemigo : estaViva()
            Enemigo -->> -GameController : false

            GameController -) +Registro_Estadistica_Sky : registrarEnemigoEliminado()
            GameController ->> +Enemigo : reaparecer()
            Enemigo -->> -GameController : Enemigo reaparece
            
        end


        GameController -->> -AvionSkyhawk : juego actualizado
        
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
