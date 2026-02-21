# Licencia — AsianOdds88 Trading System

El **AsianOdds88 Trading System** requiere una licencia válida para ejecutarse. Al arrancar (local o en EC2) se comprobará la licencia; si no hay ninguna o no es válida, se mostrará un mensaje con un enlace para obtenerla.

## Cómo usar tu licencia

1. **Variable de entorno (recomendado en servidor):**
   ```bash
   export KETER_LICENSE_KEY="<tu_token_jwt>"
   ```

2. **Archivo local (recomendado en desarrollo):**
   - Crea el archivo `local/.keter_license` en la raíz del proyecto.
   - Pon en una sola línea el token JWT que te haya proporcionado Rovidev.

El token es un JWT firmado (RS256). No lo compartas ni lo subas a repositorios públicos.

## Dónde obtener la licencia

Si aún no tienes licencia, al intentar arrancar el sistema verás el enlace para obtenerla. La URL de ese enlace es **configurable** (por defecto puede ser rovidev.com; puede cambiarse a Stripe, una landing o cualquier URL):

- Variable de entorno: **`LICENSE_OBTAIN_URL`**  
  Ejemplo: `export LICENSE_OBTAIN_URL="https://buy.stripe.com/..."`  
  Si no se define, se usa la URL por defecto del producto.

## Uso del sistema

Una vez configurada la licencia, el flujo de instalación y uso es el mismo que se describe en [INSTALACION_RAPIDA.md](INSTALACION_RAPIDA.md) y [DESPLIEGUE_AWS_COMPLETO.md](DESPLIEGUE_AWS_COMPLETO.md).
