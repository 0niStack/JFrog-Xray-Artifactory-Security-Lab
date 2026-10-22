# Troubleshooting

| Symptom | Likely cause / fix |
|---------|--------------------|
| Artifactory never becomes healthy | `docker compose logs artifactory`; check RAM (>= 4 GB); DB password mismatch (`make clean`, then `make setup`) |
| No Xray menu in UI | Xray not registered: wrong join key or `jfrogUrl`; check Xray logs; license must be Xray-enabled |
| Xray cannot reach Artifactory | Use `http://<HOST_IP>:8082`, not `localhost`; open firewall for 8082 |
| `docker push`: "server gave HTTP response to HTTPS client" | Use `localhost:8082`, or add the host to `insecure-registries` |
| `docker push` 404 / "name unknown" | Repo `docker-local` missing (`make bootstrap`) or registry access method differs |
| Scan stays pending | Xray DB sync still running; see Settings -> Database Sync and Xray logs |
| `make xray` download fails | Wrong `XRAY_VERSION`; browse the xray-compose folder on releases.jfrog.io or download manually |
| Containers OOM-killed | Give Docker more memory (Xray alone needs ~8 GB+) |
| Admin password rejected | You changed it; update `JF_ADMIN_PASSWORD` in `.env` |

Useful commands:
```bash
docker compose ps
curl -s http://localhost:8082/router/api/v1/system/health
```
