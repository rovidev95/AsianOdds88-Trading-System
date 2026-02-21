# AsianOdds88 Trading System

**El sistema número 1 para ganar de forma automática con Asian Odds 88.** Pensado para profesionales del trading deportivo y para particulares que buscan ejecución automatizada, edge matemático y control de riesgo sin estar pegados a la pantalla.

Automated trading system, sports betting software, AsianOdds88, Asian Odds 88 — ejecución en tiempo real, validación de liquidez, evaluación de valor esperado (EV) frente a consenso sharp, límites de pérdida diaria y dashboard en vivo. **Requiere licencia para ejecutarse.** Sin licencia el sistema te indicará dónde obtenerla; con ella, configuras tu entorno y arrancas.

---

## Por qué elegir AsianOdds88 Trading System

- **Ganar en automático:** pipeline completo: ingest de odds en tiempo real, validación de señales, edge matemático (bookies sharp), ejecución controlada y dashboard. No adivinar: lógica institucional, límites claros y panel para ver saldo, PnL y alertas.
- **Para profesionales y particulares:** mismo motor para operadores serios y para quien quiere automatizar sin complicarse. Redis, ejecución en local o en la nube (AWS EC2), opcional Prometheus y Grafana.
- **Control total:** stake fijo o proporcional al EV, límite de pérdida diaria, racha perdedora, cooldowns y blacklists. Dashboard web (puerto 8080): saldo, comprometido, confirmadas, rechazadas, heartbeats.

Palabras clave: automated betting, odds trading, live odds, AsianOdds88 license, betting automation, edge detection, risk controls, Rovidev, sports trading, mathematical edge, execution engine, real-time feeds.

---

## Qué necesitas para ejecutarlo

- **Licencia:** necesaria para arrancar. Si no la tienes, al iniciar el sistema verás el enlace para obtenerla.
- **Entorno:** Python 3.10+, Redis (puerto 6379), cuenta AsianOdds88 con API (Login, GetFeeds, PlaceBet, GetAccountSummary).
- **Opcional EC2:** instancia Ubuntu, puertos 22 (SSH) y 8080 (dashboard); script único de despliegue.

---

## Empezar ahora: descarga y ejecuta

1. **Obtén tu licencia** — sin ella el sistema no arranca. El enlace para conseguirla se muestra al iniciar, o puedes ir directamente a la web del producto: **[AsianOdds88 Trading System – Obtener licencia y descarga](https://rovidev.com/asianodds88/)**.
2. **Descarga el paquete** — desde el enlace que recibas al completar el proceso de licencia (instrucciones en la misma web).
3. **Configura** — copia los archivos de ejemplo (`.env.example` → `.env`, `local/remote.config.example` si usas EC2), introduce tu licencia en `KETER_LICENSE_KEY` o en `local/.keter_license`, y tus credenciales AsianOdds88 donde indique la documentación.
4. **Ejecuta** — local: script de arranque del paquete; EC2: sube y ejecuta según las instrucciones incluidas. Abre el dashboard en `http://<tu-IP>:8080`.

Si la licencia caduca o es inválida, el sistema mostrará un mensaje claro al iniciar y el enlace para renovar o obtener una nueva.

**¿Listo para automatizar?** → **[Obtener licencia y descargar →](https://rovidev.com/asianodds88/)**

---

## Documentación

| Enlace | Contenido |
|--------|-----------|
| [**Empieza ya — Descarga y ejecuta**](GET_STARTED.md) | Tres pasos: obtener licencia, descargar, configurar y ejecutar |
| [Cómo instalar y ejecutar](docs/INSTALACION_RAPIDA.md) | Pasos detallados de instalación y primer arranque |
| [Licencia](docs/LICENCIA_KETER.md) | Cómo configurar la licencia y dónde obtenerla |
| [Despliegue en AWS](docs/DESPLIEGUE_AWS_COMPLETO.md) | EC2, CloudFormation, deploy en un comando |
| [Sistema y tecnología](docs/SISTEMA_Y_TECNOLOGIA_COMPLETO.md) | Pipeline, módulos, Redis, APIs |
| [Resumen del sistema](RESUMEN_SISTEMA_COMPLETO.md) | Flujo de señales y arquitectura |

---

## Aviso legal

- El AsianOdds88 Trading System se usa bajo licencia. Consulta [docs/LICENCIA_KETER.md](docs/LICENCIA_KETER.md) y el archivo [LICENSE](LICENSE).
- Solo para mayores de edad. Las apuestas pueden estar restringidas en tu jurisdicción; el usuario es responsable del cumplimiento de la ley local.
- El software se proporciona "tal cual"; Rovidev no asume responsabilidad por pérdidas económicas o uso indebido.

---

**AsianOdds88 Trading System** — Rovidev · 2026 · [rovidev.com](https://rovidev.com) · Soporte: rovidev95@gmail.com
