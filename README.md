# JFrog Xray + Artifactory with Docker Compose (and a site to scan)

A lab stack that runs **Artifactory Pro + PostgreSQL** via Docker Compose, installs **JFrog Xray**
using JFrog's official compose installer, and includes an intentionally vulnerable
**sample website** (Node/Express + Nginx) whose images you push and scan.

```
jfrog-xray-stack/
├── docker-compose.yml        # Artifactory + PostgreSQL
├── .env.example              # copy to .env (scripts/setup.sh does it)
├── Makefile                  # shortcuts
├── scripts/                  # setup, bootstrap (repo/policy/watch), scan
├── xray/install-xray.sh      # downloads + configures official Xray compose
├── sample-site/              # vulnerable demo website (its own compose file)
└── docs/                     # detailed guides
```

## Prerequisites
- Docker Engine 24+ with the Compose v2 plugin, `curl`, `openssl`, (optional) `jq`
- ~16 GB RAM and 4+ CPUs free (Xray is heavy), 30 GB disk
- A JFrog **Xray-enabled license** (Enterprise X / Pro X) - a free trial works: <https://jfrog.com/start-free/>
- Internet access to `releases-docker.jfrog.io` and `releases.jfrog.io`

## Quick start
```bash
make setup                 # creates .env with random DB password + join key
nano .env                  # check HOST_IP, set XRAY_VERSION, pin ARTIFACTORY_VERSION
make up                    # start Artifactory (wait ~2-3 min)
# Open http://localhost:8082, log in admin/password, set a new password,
# apply your license (Administration -> Platform Management -> Licenses)
make xray                  # install + start Xray (interactive wizard)
make bootstrap             # docker-local repo, Xray indexing, policy, watch
make scan                  # build + push sample site, print scan summary
make site-up               # run the demo website at http://localhost:8080
```

Details in [docs/](docs/):
1. [Architecture](docs/01-architecture.md)
2. [Install](docs/02-install.md)
3. [Configure Xray](docs/03-configure-xray.md)
4. [Scanning the sample site](docs/04-scanning.md)
5. [Troubleshooting](docs/05-troubleshooting.md)

## Security notes
The sample site is vulnerable **on purpose**. Don't expose it publicly. Change the default
`admin` password immediately and keep `.env` out of git.
