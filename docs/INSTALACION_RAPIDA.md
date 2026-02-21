# Instalación rápida — AsianOdds88 Trading System

Guía mínima para dejar el sistema listo y en marcha (local o EC2). El **AsianOdds88 Trading System** requiere una licencia válida; al arrancar sin licencia se mostrará el enlace para obtenerla. Ver [LICENCIA_KETER.md](LICENCIA_KETER.md).

---

## Requisitos previos

- **Python 3.10+** instalado.
- **Redis** en ejecución (puerto 6379). En Windows: WSL o Redis para Windows; en Linux/Mac: `redis-server`.
- **Cuenta AsianOdds88** con acceso API (Login, GetFeeds, PlaceBet). Las credenciales se configuran en el ingest (variables de entorno o archivo de config que use el módulo).
- Para **EC2:** cuenta AWS, Key Pair `.pem`, instancia en la región que prefieras (recomendado Singapore para AsianOdds88).

---

## 1. Clonar y dependencias

```bash
git clone <url-del-repo> TradingChino
cd TradingChino
pip install -r requirements.txt
```

---

## 2. Configuración local

- **Licencia:** configura tu licencia con la variable de entorno `KETER_LICENSE_KEY` o el archivo `local/.keter_license` (una línea con el token). Si no tienes licencia, al arrancar el sistema se mostrará el enlace para obtenerla.
- **Variables de entorno:** copia `.env.example` a `.env` y ajusta si hace falta:
  - `EXECUTION_MODE=DRY` para pruebas sin apuestas reales; `LIVE` para producción.
  - `FIXED_STAKE=0.30` (o el valor que uses).
  - `REDIS_HOST` / `REDIS_PORT` si Redis no está en localhost:6379.

- **AsianOdds88:** el ingest obtiene sesión con Login/Register. Asegúrate de tener configuradas las credenciales que usa `src/asianodds_ingest.py` (env o config).

---

## 3. Arranque en tu PC (Windows)

- Ejecuta el script que arranca el stack en modo seguro, por ejemplo:
  - `.\start_live_safe_core.ps1`
- O arranca manualmente los módulos en el orden indicado en la documentación (ingest, movement_tracker, market_validator, math_edge_evaluator, etc.).

Comprueba que Redis esté en marcha antes de iniciar.

---

## 4. Arranque en EC2 (Linux)

1. **Configuración en tu PC:**  
   - Copia `local/remote.config.example` a `local/remote.config`.  
   - Rellena `REMOTE_HOST` con la IP o DNS de tu EC2.  
   - Deja la clave `.pem` en la raíz del proyecto (o indica su ruta en `SSH_KEY_PATH`).

2. **Desplegar y arrancar desde tu PC:**  
   En PowerShell, desde la raíz del proyecto:
   ```powershell
   .\scripts\aws\deploy_and_start.ps1
   ```
   El script sube código, instala dependencias en el servidor y ejecuta el arranque del stack.

3. **O solo arrancar en el servidor:**  
   Conéctate por SSH y ejecuta:
   ```bash
   cd /home/ubuntu/TradingChino   # o la ruta que uses
   bash scripts/aws/restart_all.sh
   ```

4. **Verificación:**  
   En el servidor:
   ```bash
   bash scripts/aws/verify_stack.sh
   ```
   Debe mostrar Redis OK, heartbeats recientes, sesión AsianOdds y los procesos del stack.

---

## 5. Dashboard y comprobaciones

- **Dashboard:** abre en el navegador `http://<IP-o-DNS>:8080` (en EC2 abre el puerto 8080 en el Security Group si es necesario).
- **Saldo y estado:** desde tu PC puedes usar `.\local\view_balance.ps1` y `.\local\view_logs.ps1` si tienes configurado `local/remote.config`.

---

## 6. Si algo falla

- **Redis:** `redis-cli ping` debe responder `PONG`.
- **Procesos:** en EC2, `verify_stack.sh` lista los procesos; si falta alguno, revisa `logs/live.log`.
- **Sesión AsianOdds:** el ingest hace Login/Register; si hay error de credenciales o red, aparecerá en logs.
- **Documentación detallada:** [DESPLIEGUE_AWS_COMPLETO.md](DESPLIEGUE_AWS_COMPLETO.md), [SISTEMA_Y_TECNOLOGIA_COMPLETO.md](SISTEMA_Y_TECNOLOGIA_COMPLETO.md).
