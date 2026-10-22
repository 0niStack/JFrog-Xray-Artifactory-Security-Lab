# Install

## 1. Configure
```bash
make setup
```
Edit `.env`:
- `HOST_IP` - LAN IP of the Docker host (not `localhost`; Xray containers must reach it).
- `ARTIFACTORY_VERSION` - pin a real tag from releases-docker.jfrog.io (default `latest`).
- `XRAY_VERSION` - a released version of the Xray compose installer. Browse
  `https://releases.jfrog.io/artifactory/jfrog-xray/xray-compose/`. Use a version compatible with
  your Artifactory (see JFrog's compatibility matrix).

## 2. Start Artifactory
```bash
make up
docker compose logs -f artifactory     # wait for "Artifactory successfully started"
```
Open <http://localhost:8082>, log in as `admin` / `password`, set a new password, then put it in
`.env` as `JF_ADMIN_PASSWORD`. Apply the license: *Administration -> Platform Management -> Licenses*.
Set the **Custom Base URL** to `http://<HOST_IP>:8082` (*Administration -> General -> Settings*).

## 3. Install Xray
```bash
make xray
```
The script downloads the official installer into `xray/installer/`, runs its `config.sh` wizard
(it prints the `jfrogUrl` and join key to enter), then runs `docker compose -p xray up -d`.
If the download fails, fetch the `*-compose.tar.gz` manually and extract it into `xray/installer/`
(files at the top level), then rerun. The installer's own README is authoritative if its
prompts or compose file names differ from what the script expects.

Check: the Xray menu should appear in the UI after 3-5 minutes.
Logs: `cd xray/installer && docker compose -p xray logs -f`.

## 4. Stop / remove
```bash
make down                                  # Artifactory (keeps volumes)
cd xray/installer && docker compose -p xray down
make clean                                 # also deletes data
```
