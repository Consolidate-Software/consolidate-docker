(For english instructions click [here](./README.md).)

# Consolidate On-Premise Installationsanleitung


Diese Anleitung hilft Ihnen, Consolidate On-Premise mit Docker und dem bereitgestellten `server.sh`-Skript zu installieren und zu betreiben.

**Wichtig**

Die Nutzung von Consolidate On-Premise setzt voraus, dass Sie einen Webserver sicher administrieren können, einschließlich regelmäßiger Betriebssystem-Updates, Firewall-Management und allgemeiner Serversicherheit.  
Sie sind selbst verantwortlich für Backups, Updates und die laufende Wartung Ihres Servers und Ihrer Daten.

Falls Sie sich nicht sicher sind, eine sichere und stabile Umgebung gewährleisten zu können, empfehlen wir dringend unsere Cloud-Hosting-Optionen: [Consolidate Cloud-Pläne](https://www.consolidate.eu/preise)


## Hosting-Optionen & Voraussetzungen

Während der Einrichtung können Sie zwischen zwei Hosting-Optionen wählen:

### 1. Direkte Freigabe mit Let's Encrypt

- **Beschreibung**: Die Anwendung wird direkt ins Internet freigegeben und ein TLS-Zertifikat wird automatisch mit Let's Encrypt generiert.
- **Voraussetzungen**:
   - Sie benötigen einen Domainnamen, der auf Ihren Server zeigt (statische IP oder dynamisches DNS).
   - Ihr Server muss über das Internet auf **Port 80** (für die Zertifikatsgenerierung) und **Port 443** (für HTTPS) erreichbar sein.
   - Die Firewall muss eingehenden Traffic auf Port 80 und 443 erlauben.
   - Es darf kein anderer Dienst auf Port 80 oder 443 laufen.

### 2. Freigabe über Reverse Proxy

- **Beschreibung**: Die Anwendung läuft hinter einem Reverse Proxy (z.B. Nginx, Apache oder Cloud-Loadbalancer). Der Proxy übernimmt die TLS-Zertifikatsgenerierung und -terminierung und leitet unverschlüsselten HTTP-Traffic an die Anwendung weiter.
- **Voraussetzungen**:
    - Sie benötigen einen Domainnamen, der auf Ihren Proxy-Server zeigt.
    - Ihr Reverse Proxy muss so konfiguriert sein, dass:
       - TLS-Zertifikate generiert und terminiert werden (die Anwendung selbst bietet kein HTTPS).
       - HTTP-Anfragen an den HTTP-Port der Anwendung weitergeleitet werden (während der Einrichtung konfigurierbar).
       - Die Header "X-Forwarded-For" und "X-Forwarded-Proto" gesetzt werden.
    - Für die Anwendung ist kein HTTPS-Port erforderlich; der gesamte Traffic zwischen Proxy und Anwendung ist unverschlüsselt (HTTP).
    - Die Firewall muss eingehenden Traffic zum Proxy und Traffic vom Proxy zum HTTP-Port der Anwendung erlauben.

### System-E-Mails
- **Mailserver**: Sie benötigen einen SMTP-Server, der E-Mails versenden kann. Dies ist für Systembenachrichtigungen (z.B. Termineinladungen) erforderlich.

### Hardware
- **Betriebssystem**: Linux. Empfohlen wird Ubuntu Server 24.04 LTS. Docker auf Windows kann funktionieren, ist aber ungetested.
- **Ressourcenbedarf**: Nach unserer Erfahrung sollten Sie mindestens einplanen:
  - 1 CPU-Kern und 2 GB RAM pro 20 Benutzer.
  - Passen Sie die Ressourcen entsprechend Ihrer erwarteten Benutzerzahl an.

### Software
- **Docker**: Docker muss auf Ihrem System installiert sein. [Docker installieren](https://docs.docker.com/engine/install/)
- **Git**: Git muss installiert sein. [Git installieren](https://git-scm.com/downloads)

## Installationsschritte

1. **Repository klonen**

   Öffnen Sie ein Terminal und führen Sie aus:
   ```bash
   git clone https://github.com/Consolidate-Software/consolidate-docker.git
   cd consolidate-docker
   ```

2. **Setup-Skript ausführen**

   Das Hauptskript für die Einrichtung und Verwaltung ist `server.sh`. Sie müssen es ggf. ausführbar machen:
   ```bash
   chmod +x server.sh
   ```

   Um die Anwendung zu konfigurieren, führen Sie aus:
   ```bash
   ./server.sh configure
   ```
   Das Skript fragt die Konfigurationsdetails ab und erstellt eine `.env`-Datei.

3. **Anwendung starten**

   Um die Anwendung zu starten:
   ```bash
   ./server.sh start
   ```

4. **Anwendung stoppen**

   Um die Anwendung zu stoppen:
   ```bash
   ./server.sh stop
   ```

5. **Anwendung aktualisieren**

   Um auf die neueste Version zu aktualisieren:
   ```bash
   ./server.sh update
   ```
   Dies lädt den neuesten Code und aktualisiert die laufenden Container.

## Zusätzliche Hinweise

- Sie können die Logs anzeigen mit:
  ```bash
  docker compose logs -f
  ```
- Bei Berechtigungsproblemen mit Docker stellen Sie sicher, dass Ihr Benutzer in der `docker`-Gruppe ist oder führen Sie das Skript mit `sudo` aus.
