# Obeeba AI Chatbox image builder

This public repository stores the Dockerfile and GitHub Actions workflow. The workflow checks out the private source repository only on its temporary runner, builds the FastAPI service image, and publishes it to GitHub Container Registry (GHCR).

## Configure source access

Before the first workflow run, add this repository secret:

1. Open **Settings → Secrets and variables → Actions → New repository secret**.
2. Set the name to **SOURCE_REPO_TOKEN**.
3. Set the value to a fine-grained GitHub token that can read **obeeba-hq/obeeba-ai-chatbox** (**Contents: read**).

The workflow uses this token only for the private source checkout. It uses the job-scoped GITHUB_TOKEN with **packages: write** to publish the image. Do not commit a token or .env file.

## Build triggers and image tags

The workflow runs on pushes to **main** or a manual dispatch. It publishes:

- **ghcr.io/xjjdev/obeeba-ai-chatbox-image:latest** for the default branch
- A branch tag
- A short commit SHA tag

The GHCR package is private by default. Grant package access to deployments that need to pull it. The public status of this builder repository does not make the image package public.

## Run the image

The service listens on port **8088**. Supply runtime settings through a local environment file; keep real credentials out of this repository. At minimum, configure **MYSQL_DSN** for the MySQL database and **OPENAI_API_KEY** for model calls. Set **INTERNAL_API_BASE_URL** and any S3/CORS settings required by the deployment.

Run database migrations after creating the database:

~~~sh
docker run --rm --env-file .env ghcr.io/xjjdev/obeeba-ai-chatbox-image:latest alembic upgrade head
~~~

Then start the service:

~~~sh
docker run --rm -p 8088:8088 --env-file .env ghcr.io/xjjdev/obeeba-ai-chatbox-image:latest
~~~

Health check: **GET /healthz**. The debug console is served at **/debug**.
