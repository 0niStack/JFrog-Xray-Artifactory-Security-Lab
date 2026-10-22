# Configure Xray

`make bootstrap` calls the REST APIs to do everything below. You can also do it by hand.

| Step | UI path | API used by script |
|------|---------|--------------------|
| Create Docker repo `docker-local` | Administration -> Repositories -> Local -> Docker | `PUT /artifactory/api/repositories/docker-local` |
| Index it in Xray | Administration -> Xray -> Indexed Resources | `POST /xray/api/v1/binMgr/default/repos` |
| Policy `block-high-and-critical` | Xray -> Watches & Policies -> Policies | `POST /xray/api/v2/policies` |
| Watch `docker-local-watch` | Xray -> Watches & Policies -> Watches | `POST /xray/api/v2/watches` |

## Policy
Security policy, rule: minimum severity **High**; actions: *block download* (scanned artifacts only)
and *fail build*. Add a **License** policy (e.g. deny GPL) the same way if needed.

## Docker access method
Artifactory is exposed on `:8082`. With the repo-path method, images are referenced as
`localhost:8082/docker-local/<image>:<tag>`. Docker treats `localhost` as a trusted (HTTP) registry.
For a remote host, put a TLS reverse proxy in front, or add the host to `insecure-registries` in
`/etc/docker/daemon.json` and restart Docker.

## Database sync
After first start Xray downloads its vulnerability DB; first scans may wait until it finishes
(*Xray -> Settings -> Database Sync*). Needs internet access to JFrog.
