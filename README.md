<img width="541" height="728" alt="1" src="https://github.com/user-attachments/assets/5fdf196f-286c-4952-a1e0-c167ff2ed905" />

                        🎯 REDTEAM SCANNER 🛡️ PowerShell Toolkit para Evaluación de Seguridad Ofensiva By AnonSec777

🚀 ¿Qué es esto?
Un orquestador de reconocimiento todo-en-uno para Windows que automatiza la fase de information gathering en pruebas de penetración. ¡Integra las mejores herramientas open-source en un flujo único y elegante! ✨


🔥 Características Principales

🕵️ Descubrimiento Inteligente

🔍 Escaneo de Puertos (Nmap + fallback TCP nativo)

🌐 Detección Web (HTTPX ultrarrápido o PowerShell manual)

🗂️ Subdominios (Integración con Subfinder)

🚪 Fuzzing de Directorios (Gobuster con wordlists dinámicas)

⚡ Modo Resiliente

🧠 Autodetección de herramientas instaladas

🛟 Fallbacks nativos si faltan dependencias

🎨 Logging colorido en tiempo real

📊 Reportes automáticos con timestamps

🛠️ Stack Tecnológico

🔵 PowerShell 5.1+  |  🟢 Go Tools  |  🟡 Nmap  |  🔴 Nuclei

📋 Flujo de Trabajo Visual


🎯 Dominio Objetivo
    
    ↓

🔧 Detección de Herramientas
    
    ↓

⚡ 

Escaneo de Puertos ───┐

🌐 Servicios Web ────────┼──→ 📁 Generación de Reportes

🗂️ Subdominios ─────────┤    📝 Resumen Ejecutivo

🚪 Fuzzing Directories ──┘    ⏱️  Métricas de Tiempo
    
    ↓

🛡️ Análisis de Vulnerabilidades (Nuclei)

🖥️ Requisitos del Sistema
Componente	Estado	Descripción

💻 Windows	

✅ Obligatorio	PowerShell 5.1 o superior

🌐 Nmap	

⚡ Opcional	Escaneo avanzado de puertos

🎯 Subfinder	

⚡ Opcional	Enumeración DNS

🚀 HTTPX	

⚡ Opcional	Detección web rápida

🚪 Gobuster	

⚡ Opcional	Fuzzing de directorios

⚠️ Nuclei	

⚡ Opcional	Scanner de vulnerabilidades

💡 Tip: Las herramientas Go se detectan automáticamente en %USERPROFILE%\go\bin\


🎮 Modo de Uso

# Ejecución básica

.\redteam.ps1 -target "empresa.com"


# Ejemplo con output bonito:

🟢 [14:32:15] Dominio validado: empresa.com

🟡 [14:32:16] Detectando herramientas...

🟢 [14:32:16] OK: nmap

🟢 [14:32:16] OK: subfinder

🔵 [14:32:18] Puertos abiertos encontrados: 3

🟢 [14:32:25] Subdominios encontrados: 47

✅ ¡Reporte generado en outputs/empresa_com/!

📦 Estructura de Salida

📂 outputs/
└── 📁 empresa_com/
    ├── 📄 nmap_scan.txt          ← 🔍 Puertos y servicios
    ├── 📄 web_alive.txt          ← 🌐 URLs activas
    ├── 📄 subdominios.txt        ← 🗂️ Subdominios descubiertos
    ├── 📄 directorios.txt        ← 🚪 Paths sensibles
    ├── 📄 vulnerabilidades.txt   ← ⚠️ CVEs detectados
    └── 📄 reporte_final.txt      ← 📊 Resumen ejecutivo

⚠️ Disclaimer Ético 🛡️

🚨 USO RESPONSABLE


Esta herramienta está diseñada exclusivamente para:


✅ Auditorías de seguridad autorizadas

✅ Pruebas de penetración con consentimiento

✅ Laboratorios de aprendizaje propios

El uso no autorizado contra sistemas ajenos es ilegal. 🚫


🌟 ¿Por qué usarlo?

🎩 Profesional: Detecta automáticamente tu entorno y se adapta

⚡ Rápido: Ejecución paralela con manejo de errores robusto

🎨 Visual: Colores, emojis y logs claros (¡no más pantallas aburridas!)

📱 Portable: Un solo archivo .ps1, sin instalación compleja

🔐 Hecho con 💙 para la comunidad de ciberseguridad

¿Listo para tu próximo assessment? ¡Ejecuta el script y descubre tu superficie de ataque! 🚀

Nuestras Redes Sociales

Telegram

https://t.me/PlantillasNucleiHackingTeam

https://t.me/HackingTeamGrupoOfficial

https://t.me/+0hHSaKO7eI9mNWY8 Hacking Team Difusion

https://t.me/+llcmNGzz6JIyMmI0 Biblioteca

https://t.me/TermuxHackingTeam

X

@HackingTeam77

Bluesky

https://bsky.app/profile/hackingteam.bsky.social

Discord

https://discord.gg/V4nPFbQX

Facebook

https://www.facebook.com/groups/hackingteam2022/?ref=share https://www.facebook.com/groups/HackingTeamCyber/?ref=share

Youtube

https://www.youtube.com/@HackingTeamOfficial

Canal de tiktok

https://www.tiktok.com/@hacking.kdea?_t=ZS-8vTtlaQrDTL&_r=1

#hackingteam #cibersecurity #infosec #eticalhacking #pentesting #dns #script #cracking #hack #security #bugbounty #payload #tools #exploit #cors #sqli #ssrf #python #c2 #poc #web #ramsomware #phishing #linux #osint #linux #windows #redteam #blueteam #spyware #digitalforensics #reverseengineeringtools #rat #malwareforensics #exploitdevelopment #sandboxing #apt #zerodayexploit #xss #github #cve #java #tools #termux #troyano    #dev #sqlmap #waybackurls #copilot #ai #ia #kalilinux #parrot #dracos #susse #nessus #oswazap #burpsuite #wireguar
