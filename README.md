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

En `mobile`, ejecutar `flutter create --platforms=android --project-name control_gestantes .`, después `flutter pub get` y `flutter run`. El primer comando genera los archivos nativos de Android que no se incluyen aún porque Flutter no estaba instalado al preparar este repositorio. No reemplazar `lib/` si la herramienta pregunta.

La aplicación inicial muestra la pantalla principal y navegación de ejemplo; **no guarda ni sincroniza datos todavía**. No introducir información de pacientes.

### API

En `backend`, copiar `.env.example` como `.env`, configurar una base de datos MySQL local y ejecutar `npm install`, `npm run build` y `npm run start:dev`. `GET /api/health` comprueba el proceso; `GET /api/health/database` comprueba la conexión a MySQL. No se crean tablas ni se almacenan datos clínicos en esta etapa.

Nunca subir `.env`, datos personales, llaves o credenciales al repositorio.
