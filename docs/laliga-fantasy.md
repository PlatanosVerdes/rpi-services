# laliga-fantasy

**Sesion.** El login es un OAuth por navegador, que un contenedor no puede hacer. No hace falta
copiar nada a mano: si no hay sesion, la propia pagina la pide. Abre
`https://fantasy.platanosverdes.com`, pulsa el enlace de login, y pega la direccion a la que te
redirija (fallara al abrir `authredirect://…`, eso es lo normal: el codigo esta en la barra).
Tambien acepta un `tokens.json` pegado tal cual, y lo comprueba contra la API antes de aceptarlo.

A partir de ahi el refresh token rota solo y el fichero se actualiza en su sitio, asi que es cosa
de una vez. `/healthz` dice cuanta vida le queda a la sesion, que es lo que convierte "se me ha
muerto el token" en un aviso en vez de en una sorpresa.

**Acceso.** Solo se llega desde el tailnet, y eso es toda la puerta: la pagina puede gastar
dinero real de la liga, asi que lo que la protege es que nadie mas llegue. Nada se ejecuta sin
confirmarlo en la pagina, y las instrucciones permanentes solo actuan dentro de los limites que
se les pongan ahi. Con `--read-only` en el `command` se sirve la pagina y se rechaza cualquier
operacion, por si algun dia interesa mirar sin poder tocar.
