---
title: "Productive K3S Infra"
template: "home.html"
hide:
  - navigation
  - toc
eyebrow: "Infrastructure scenarios for Productive K3S"
eyebrow_es: "Escenarios de infraestructura para Productive K3S"
hero_title: "Productive K3S Infra"
hero_title_es: "Productive K3S Infra"
lead: "Productive K3S Infra provides pre-assembled infrastructure flows for running Productive K3S on local virtual machines, basic cloud setups, and existing on-premises hosts."
lead_es: "Productive K3S Infra ofrece flujos de infraestructura prearmados para ejecutar Productive K3S sobre máquinas virtuales locales, setups cloud básicos y hosts on-premises existentes."
sublead: "It focuses on provisioning, inventories, networking assumptions, bootstrap orchestration, and validation, while Productive K3S remains the cluster bootstrap layer."
sublead_es: "Se enfoca en provisioning, inventarios, supuestos de red, orquestación del bootstrap y validación, mientras que Productive K3S sigue siendo la capa de bootstrap del clúster."
primary_label: "View on GitHub"
primary_label_es: "Ver en GitHub"
primary_url: "https://github.com/jemacchi/productive-k3s-infra"
secondary_label: "Open README"
secondary_label_es: "Abrir README"
secondary_url: "https://github.com/jemacchi/productive-k3s-infra/blob/main/README.md"
card_title: "What it does"
card_title_es: "Qué hace"
card_items:
  - Provisions or targets infrastructure for Productive K3S
  - Reuses shared OpenTofu and Ansible-based orchestration layers
  - Validates complete scenarios through static, contract, and live checks
card_items_es:
  - Provisiona o apunta infraestructura para Productive K3S
  - Reutiliza capas compartidas de orquestación con OpenTofu y Ansible
  - Valida escenarios completos con checks static, contract y live
why_title: "Why it exists"
why_title_es: "Por qué existe"
why_options:
  - label: "DIY INFRASTRUCTURE"
    text: "Raw infrastructure scripts are flexible, but inconsistent and hard to reuse."
  - label: "FULL PLATFORM"
    text: "A fully productized platform can be powerful, but too heavy for early adoption and evaluation."
why_options_es:
  - label: "INFRAESTRUCTURA DIY"
    text: "Los scripts de infraestructura crudos son flexibles, pero inconsistentes y difíciles de reutilizar."
  - label: "PLATAFORMA COMPLETA"
    text: "Una plataforma completamente productizada puede ser potente, pero demasiado pesada para adopción y evaluación temprana."
bridge_note: "Productive K3S Infra provides the middle path: repeatable infrastructure flows around Productive K3S."
bridge_note_es: "Productive K3S Infra ofrece el camino intermedio: flujos repetibles de infraestructura alrededor de Productive K3S."
bridge_points:
  - Keep Productive K3S as the bootstrap contract
  - Package real scenarios instead of toy examples
  - Make local, cloud, and SSH-based validation predictable
bridge_points_es:
  - Mantener Productive K3S como contrato de bootstrap
  - Empaquetar escenarios reales en lugar de ejemplos de juguete
  - Hacer predecible la validación local, cloud y basada en SSH
scenarios_title: "Target scenarios"
scenarios_title_es: "Escenarios objetivo"
scenarios:
  - Local multi-node validation with Multipass
  - Existing hosts reachable over SSH
  - Basic single-node cloud evaluation on AWS
  - Teams that want reusable infrastructure flows before custom hardening
scenarios_es:
  - Validación local multinodo con Multipass
  - Hosts existentes alcanzables por SSH
  - Evaluación cloud básica de nodo único en AWS
  - Equipos que quieren flujos reutilizables de infraestructura antes del hardening propio
principles_title: "Design principles"
principles_title_es: "Principios de diseño"
principles:
  - title: "Scenarios first"
    text: "public entry points are complete deployment flows, not fragments"
  - title: "Reuse shared layers"
    text: "keep provisioning and remote bootstrap logic aligned"
  - title: "Stay explicit"
    text: "node roles, generated metadata, and make targets should be obvious"
principles_es:
  - title: "Escenarios primero"
    text: "los entrypoints públicos son flujos completos de despliegue, no fragmentos"
  - title: "Reutilizar capas compartidas"
    text: "mantener alineada la lógica de provisioning y bootstrap remoto"
  - title: "Mantenerlo explícito"
    text: "roles de nodos, metadata generada y targets de make deben ser evidentes"
environments_title: "Supported environments"
environments_title_es: "Entornos soportados"
environments:
  - Multipass on a local development machine
  - Existing Ubuntu or Debian hosts reachable over SSH
  - Basic AWS EC2 single-node setups
  - Productive K3S source bundles from a local checkout or a published release
environments_es:
  - Multipass en una máquina de desarrollo local
  - Hosts Ubuntu o Debian existentes alcanzables por SSH
  - Setups básicos de nodo único sobre AWS EC2
  - Bundles de Productive K3S desde un checkout local o un release publicado
not_title: "What it is not"
not_title_es: "Qué no es"
not_items:
  - Not a replacement for Productive K3S
  - Not a managed platform or a hardened production framework
  - Not a promise that every public scenario is production-ready as-is
not_items_es:
  - No reemplaza a Productive K3S
  - No es una plataforma administrada ni un framework endurecido para producción
  - No promete que cada escenario público esté listo para producción tal como viene
not_note: "It is the infrastructure companion layer around Productive K3S."
not_note_es: "Es la capa compañera de infraestructura alrededor de Productive K3S."
---
