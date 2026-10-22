# Architecture

```
 Docker host
 ├─ docker-compose.yml  (project: jfrog-platform)
 │    ├─ artifactory-postgres   :5432 (internal)
 │    └─ artifactory            :8081, :8082  <- UI, REST, Docker registry
 ├─ xray/installer (project: xray, official JFrog compose)
 │    └─ xray services + (optional) bundled PostgreSQL / RabbitMQ
 └─ sample-site/docker-compose.yml (project: sample-site)
      ├─ app  (Node 16 + Express, old deps)
      └─ web  (Nginx 1.18 reverse proxy) :8080
```

**Flow:** you push an image to `docker-local` in Artifactory -> Artifactory notifies Xray ->
Xray indexes layers/packages and matches them against its vulnerability and license database ->
a *Watch* applies *Policies* -> violations show in the UI/API and can block download or fail builds.

**Why two compose projects?** Xray is shipped and supported as its own compose installer with its
own services. Both stacks talk over the host IP (`HOST_IP`) and share one **join key**, so Xray
can register itself with Artifactory's Access service.
