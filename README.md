# Proyecto de control de madres gestantes

Aplicación móvil para acompañamiento prenatal, basada en el diseño de Rimaykullayki. La primera plataforma prevista es Android. El proyecto está en fase inicial: no debe utilizarse todavía con datos reales ni para tomar decisiones clínicas.

## Estructura

- `mobile/`: aplicación Flutter y Dart.
- `backend/`: API NestJS y TypeScript con conexión a MySQL.
- `docs/`: decisiones y trabajo pendiente.

## Requisitos

- Flutter SDK estable, Android Studio y un emulador o teléfono Android configurado. Ver [instalación oficial de Flutter](https://docs.flutter.dev/get-started/install/windows/mobile).
- Node.js compatible con NestJS, npm y MySQL 8.
- Git.

## Inicio

### Aplicación Android

La compilación de prueba se ejecuta en GitHub Actions y deja el APK como artefacto de la ejecución. Para compilar localmente, instalar Flutter y el SDK de Android, y ejecutar `flutter pub get` y `flutter run` en `mobile`. Se requieren Android 7.0 (API 24) o posterior y Java 17 o superior.

La versión de desarrollo permite registrar un perfil y controles localmente en una base SQLCipher, con la clave en almacenamiento seguro del dispositivo. Todavía no hay cuentas, recuperación, sincronización con MySQL ni validación clínica. **Usar únicamente datos ficticios**, hasta completar y verificar las medidas de seguridad en Android.

La copia de seguridad automática de Android está desactivada: desinstalar la aplicación o perder el dispositivo puede hacer perder los datos locales. La configuración de firma y el identificador Android aún son provisionales; no usar esta configuración para publicar una versión de producción.

### API

En `backend`, copiar `.env.example` como `.env`, configurar una base de datos MySQL local y ejecutar `npm install`, `npm run build` y `npm run start:dev`. `GET /api/health` comprueba el proceso; `GET /api/health/database` comprueba la conexión a MySQL. No se crean tablas ni se almacenan datos clínicos en esta etapa.

Nunca subir `.env`, datos personales, llaves o credenciales al repositorio.
