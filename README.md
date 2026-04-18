# 🩸 GulcosaGarmin

App nativa para dispositivos Garmin (Connect IQ / Monkey C) que muestra la glucosa en tiempo real desde **FreeStyle Libre (Abbott)** vía la API de LibreLink Up.

## ✨ Funcionalidades

- 📊 **Glucosa actual** en pantalla del reloj, actualizada cada 5 minutos
- 🔴 **Alertas de hipoglucemia** (< 70 mg/dL) con vibración
- 🟡 **Alertas de hiperglucemia** (> 180 mg/dL) con vibración
- 🔄 Sincronización automática en segundo plano

## 🏗️ Arquitectura

```
Sensor Libre → LibreLinkUp App → LibreLinkUp API → Garmin Watch (esta app)
```

La app consulta la API REST de LibreLinkUp directamente desde el reloj usando el módulo `Communications` de Connect IQ.

## 📁 Estructura del proyecto

```
GulcosaGarmin/
├── manifest.xml              # Metadatos y permisos de la app
├── monkey.jungle             # Configuración de compilación
├── resources/
│   ├── layouts/
│   │   └── layout.xml        # Layout de la pantalla principal
│   ├── strings/
│   │   └── strings.xml       # Textos y mensajes
│   └── drawables/
│       └── drawables.xml     # Recursos gráficos
└── source/
    ├── GulcosaGarminApp.mc   # Punto de entrada de la app
    ├── GulcosaGarminView.mc  # Vista principal (pantalla del reloj)
    ├── LibreApi.mc           # Cliente de la API LibreLinkUp
    ├── AlertManager.mc       # Gestión de alertas y vibraciones
    └── DataStore.mc          # Almacenamiento local de datos
```

## 🚀 Instalación y desarrollo

### Requisitos

- [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) (>= 4.0)
- Cuenta en [LibreLink Up](https://librelinkup.com/) con datos compartidos activos
- Reloj Garmin compatible con Connect IQ

### Configurar credenciales

En el simulador o en el reloj, al iniciar la app se pedirán:
- **Email** de LibreLink Up
- **Contraseña** de LibreLink Up

Estas se guardan de forma segura en el almacenamiento local del reloj.

### Compilar y ejecutar

```bash
# Con el SDK instalado:
monkeyc -f monkey.jungle -o GulcosaGarmin.prg -d fenix6pro -y developer_key.der

# O usar el simulador en VS Code con la extensión oficial de Garmin
```

## ⚠️ Umbrales de alerta (configurables)

| Estado | Valor por defecto |
|--------|-------------------|
| Hipoglucemia | < 70 mg/dL |
| Rango objetivo bajo | 70 mg/dL |
| Rango objetivo alto | 180 mg/dL |
| Hiperglucemia | > 180 mg/dL |

## 📋 Notas importantes

- La API de LibreLinkUp **no es oficial**. Úsala bajo tu responsabilidad.
- Los datos se actualizan cada **5 minutos** (frecuencia del sensor Libre).
- Esta app es un **complemento**, no un dispositivo médico. Consulta siempre con tu médico.

## 📄 Licencia

MIT — ver [LICENSE](LICENSE)
