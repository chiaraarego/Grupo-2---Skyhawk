# Diagrama de clases — Módulo Skyhawk

Basado en el diagrama de clases 

## 1. Cargar la partida, el avión e iniciar el juego
```mermaid
sequenceDiagram
    actor Jugador

    participant AvionSkyhawk
    participant GameController
    participant Jugador_Avion
    participant Enemigo

    Jugador ->> +AvionSkyhawk : iniciar juego

    %% AvionSkyhawk se auto-llama para inicializar
    AvionSkyhawk ->> +AvionSkyhawk : iniciar()

    %% Crea el controlador del juego
    AvionSkyhawk ->> +GameController : GameController()

    %% El controlador crea al avión del jugador
    GameController ->> +Jugador_Avion : Jugador_Avion(xPos, yPos)
    Jugador_Avion -->> -GameController : devuelve xpos, ypos

    %% El controlador se auto-llama para crear la horda de enemigos
    GameController ->> +GameController : crearEnemigos()

    loop por cada enemigo inicial
        GameController ->> +Enemigo : Enemigo(xPos, yPos)
        Enemigo -->> -GameController : devuelve xpos, ypos
    end

    %% Van cerrándose ordenadamente las ejecuciones abiertas de atrás hacia adelante
    GameController -->> -GameController : enemigos creados
    GameController -->> -AvionSkyhawk : controlador listo
    AvionSkyhawk -->> -AvionSkyhawk : inicialización completa
    
    %% RESPUESTA FINAL AL JUGADOR:
    AvionSkyhawk -->> -Jugador : muestra pantalla de juego (render)
```

## 2. Mover el avión (arriba, abajo, izquierda, derecha)

```mermaid
sequenceDiagram
    actor Jugador
    participant AvionSkyhawk
    participant GameController
    participant Jugador_Avion

    Jugador ->> +AvionSkyhawk : presiona tecla de movimiento

    AvionSkyhawk ->> +GameController : actualizar()

    %% Abre la activación interna para leer el teclado
    GameController ->> +GameController : leerTeclado()

    alt tecla ARRIBA
        GameController ->> +Jugador_Avion : mover(Direccion.ARRIBA)
        Jugador_Avion -->> -GameController : 
    else tecla ABAJO
        GameController ->> +Jugador_Avion : mover(Direccion.ABAJO)
        Jugador_Avion -->> -GameController : 
    else tecla IZQUIERDA
        GameController ->> +Jugador_Avion : mover(Direccion.IZQUIERDA)
        Jugador_Avion -->> -GameController : 
    else tecla DERECHA
        GameController ->> +Jugador_Avion : mover(Direccion.DERECHA)
        Jugador_Avion -->> -GameController : 
    end

    %% Cierra la lectura del teclado primero
    GameController -->> -GameController : teclado procesado
    
    %% Retorna el flujo al objeto principal de la app
    GameController -->> -AvionSkyhawk : estado actualizado

    %% RESPUESTA FINAL AL JUGADOR:
    AvionSkyhawk -->> -Jugador : actualiza posición del avión en pantalla
```

## 3. Disparar y matar un enemigo
```mermaid
sequenceDiagram
    actor Jugador

    participant AvionSkyhawk
    participant GameController
    participant Jugador_Avion
    participant ProyectilSkyhawk
    participant Enemigo

    Jugador ->> +AvionSkyhawk : activa disparo

    AvionSkyhawk ->> +GameController : dispararSkyhawk()

    GameController ->> +Jugador_Avion : disparar()
    Jugador_Avion -->> -GameController : instancia de ProyectilSkyhawk

    GameController -->> -AvionSkyhawk : proyectil registrado en el juego

    AvionSkyhawk -->> -Jugador : dibuja disparo en pantalla

    loop hasta que el proyectil impacta o sale de pantalla
        AvionSkyhawk ->> +GameController : actualizar()

        GameController ->> +ProyectilSkyhawk : actualizar()
        ProyectilSkyhawk -->> -GameController : posición avanzada

        GameController ->> +GameController : detectarColisiones()

        GameController ->> +ProyectilSkyhawk : getX()
        ProyectilSkyhawk -->> -GameController : x

        GameController ->> +ProyectilSkyhawk : getY()
        ProyectilSkyhawk -->> -GameController : y

        GameController ->> +Enemigo : colisionaCon(x, y)
        Enemigo -->> -GameController : true

        alt proyectil impacta al enemigo
            GameController ->> +Enemigo : recibirDanio(1)
            Enemigo -->> -GameController : daño aplicado
            
            GameController ->> +Enemigo : estaViva()
            Enemigo -->> -GameController : false
        end

        GameController -->> -GameController : colisión procesada

        GameController -->> -AvionSkyhawk : lógica de juego actualizada
        
        %% Respuesta visual en cada vuelta del loop para avisar al jugador
        alt Si el enemigo murió
            AvionSkyhawk -->> Jugador : muestra explosión y suma puntos
        else El proyectil sigue viajando
            AvionSkyhawk -->> Jugador : redibuja proyectil en movimiento
        end
    end
```

## 4. Morir (por colisión / choque de proyectil)
```mermaid
sequenceDiagram
    participant AvionSkyhawk
    participant GameController
    participant ProyectilEnemigo
    participant Jugador_Avion

    loop hasta que el proyectil enemigo impacta o sale de pantalla
        AvionSkyhawk ->> +GameController : actualizar()

        GameController ->> +ProyectilEnemigo : actualizar()
        ProyectilEnemigo -->> -GameController : 

        GameController ->> +GameController : detectarColisiones()

        GameController ->> +ProyectilEnemigo : getX()
        ProyectilEnemigo -->> -GameController : x

        GameController ->> +ProyectilEnemigo : getY()
        ProyectilEnemigo -->> -GameController : y

        GameController ->> +Jugador_Avion : colisionaCon(x, y)
        Jugador_Avion -->> -GameController : true

        alt proyectil impacta al avión
            GameController ->> +Jugador_Avion : recibirDanio(1)
            Jugador_Avion -->> -GameController : 

            GameController ->> +Jugador_Avion : estaViva()
            Jugador_Avion -->> -GameController : false
        end

        GameController -->> -GameController : 
        GameController -->> -AvionSkyhawk : 
    end

    AvionSkyhawk ->> +GameController : jugadorVivo()
    GameController -->> -AvionSkyhawk : false

    AvionSkyhawk ->> +AvionSkyhawk : finalizar()
```