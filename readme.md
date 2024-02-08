### Título del Script: Configuración de dominio en servidor Bind9 en Ubuntu

#### Readme.md

---

**Antes de comenzar:**
Primeramente aclarar que el primer objetivo de este script es que de forma fácil las personas dueñas de un VPS y dueñas de dominios cubano, puedan crearse rápidamente un servidor DNS para controlar esos dominios, pero sirve para cualquier dominio y VPS en el mundo. 
Antes de ejecutar este script, asegúrate de haber actualizado e instalado las últimas actualizaciones y dependencias del sistema utilizando los siguientes comandos:

```bash
sudo apt update
sudo apt upgrade
```

**Uso del script:**

1. Ejecuta este script en tu servidor VPS que desees configurar como servidor DNS.
2. Durante la ejecución, se te pedirá que ingreses el dominio(ejemplo.cu) que deseas configurar. Asegúrate de tener la información del dominio disponible.
3. El script instalará Bind9 y Nano, y realizará la configuración necesaria para establecer tu servidor como servidor DNS autoritativo para el dominio especificado.
4. Dame una estrella al repositorio, (no funcionará de lo contrario😔)

**Notificación a NIC-STAFF:**

Después de ejecutar el script y completar la configuración de Bind9, debes enviar un correo electrónico a nic-staff@nic.cu desde la cuenta asociada al dominio para informarles que deseas que apunten tu dominio a tu VPS. Asegúrate de incluir toda la información relevante, como la dirección IP del servidor DNS y cualquier otro detalle que consideres importante.

**Mensaje de ejemplo:**

```plaintext
Asunto: Solicitud de apuntamiento de dominio

Estimado equipo de NIC-STAFF,

Me gustaría solicitar que mi dominio, [tu_dominio], se apunte a la siguiente dirección IP: [dirección_IP_del_servidor_DNS]. 

Agradezco su atención y espero su confirmación. Gracias.

Saludos cordiales,
[Tu Nombre]
[Tu Correo Electrónico]
[Tu Número de Teléfono]
```

**Nota:** Debes esperar un tiempo a que se propaguen todos los dns, si quieres saber con certeza si funcionó lo que hiciste, puedes chequear systemctl status bind9, para ver si no hay ningún error, también desde otra computadora puedes usar nslookup tudominio.cu tu_dirección_IP_del_servidor_DNS
