# Arquitectura inicial

Android primero. Flutter/Dart en el cliente; API REST con NestJS/TypeScript y MySQL como base central. El código móvil se organizará por funcionalidades y separará interfaz, lógica y acceso a datos. El backend será un monolito modular.

La primera versión está dirigida a gestantes de Abancay, con ayuda opcional de un familiar o agente comunitario. La variante de quechua y la información de los establecimientos y contactos deben validarse localmente.

## Prioridades antes de usar datos reales

1. Definir usuarios, acceso, consentimiento, recuperación y permisos de gestantes, familiares y agentes.
2. Diseñar almacenamiento local cifrado y gestión de claves; definir recuperación ante pérdida del dispositivo y sincronización con resolución de conflictos.
3. Validar con profesionales las reglas de cálculo, las preguntas y las alertas. El cuestionario de Figma es ilustrativo y no debe diagnosticar.
4. Acordar variante de quechua, traducciones y grabaciones validadas con la comunidad.
5. Definir qué mapa, contactos y contenidos se descargan para uso sin conexión.
6. Implementar auditoría, respaldo y restauración, seguridad de API y políticas de retención.

## Estado

La primera entrega es una base técnica sin persistencia de datos de gestantes. La pantalla móvil es una demostración visual y no debe emplearse con información real.
