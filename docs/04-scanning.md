# Scanning the sample website

## The sample site
`sample-site/` is an Express app (old `express`, `lodash`, `minimist`, `axios`, on `node:16-alpine`)
behind `nginx:1.18-alpine`. Both are outdated on purpose so Xray reports findings.

Run it locally: `make site-up` -> <http://localhost:8080> (`/api/info` returns JSON).

## Scan via Artifactory (what `make scan` does)
1. `docker login localhost:8082`
2. `docker compose -f sample-site/docker-compose.yml build`
3. `docker push localhost:8082/docker-local/sample-app:1.0.0` (and `sample-web`)
4. Xray indexes the pushed image automatically (watch + indexed repo).
5. The script queries `POST /xray/api/v1/summary/artifact` and prints counts by severity.

UI: *Xray -> Scans List -> Repositories -> docker-local*, or Artifactory -> Artifacts ->
docker-local -> sample-app -> 1.0.0 -> *Xray Data*.

## Scan with the JFrog CLI (optional)
```bash
curl -fL https://install-cli.jfrog.io | sh
jf config add local --url=http://localhost:8082 --user=admin --password=<pw> --interactive=false
cd sample-site/app && jf audit --licenses          # scan app dependencies
jf docker scan localhost:8082/docker-local/sample-app:1.0.0
```
(Some CLI scan features depend on your JFrog license tier.)

## Prove the policy works
Once the scan finishes, `docker pull localhost:8082/docker-local/sample-app:1.0.0` should be
**blocked** if it has High/Critical issues. Violations: *Xray -> Violations*.

## Fix and rescan
Upgrade deps in `sample-site/app/package.json` (current `express`, `lodash`, `axios`), switch to
current base images, bump the tag, run `TAG=1.0.1 make scan`, and compare results.
