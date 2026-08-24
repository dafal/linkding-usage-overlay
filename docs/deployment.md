# Deployment

The production deployment should use the immutable image tag shown in
`compose.example.yaml`. Do not deploy `latest` or automatically follow upstream
releases, because every upstream version must be checked against the patch.

## Publish

Configure Docker Hub credentials as GitHub Actions secrets without placing the
token in repository files or command history:

```bash
gh secret set DOCKERHUB_USERNAME --repo dafal/linkding-usage-overlay
gh secret set DOCKERHUB_TOKEN --repo dafal/linkding-usage-overlay
```

Run the manual `Publish image` workflow after the validation workflow succeeds:

```bash
gh workflow run publish.yaml --repo dafal/linkding-usage-overlay --ref main
```

## Back Up SQLite

Set `data_dir` to the host directory mounted at `/etc/linkding/data`. Stop the
application while copying the database so the backup cannot omit a pending
SQLite transaction.

```bash
data_dir=/path/to/linkding/data
backup="${data_dir}/db.sqlite3.$(date +%Y%m%d%H%M%S).bak"

docker compose stop linkding
cp "${data_dir}/db.sqlite3" "${backup}"
sqlite3 "file:${backup}?immutable=1" "PRAGMA integrity_check;"
docker compose start linkding
```

Keep the backup until the upgraded instance has been verified.

## Upgrade

Update the Compose image to the versioned usage-tracking image, then recreate
the service:

```bash
docker compose pull linkding
docker compose up -d linkding
docker compose logs --tail=100 linkding
```

For a database previously used with the legacy fork, the expected new Linkding
v1.46.2 migrations are:

```text
0052_apitoken
0053_migrate_api_tokens
0054_bookmarkbundle_filter_shared_and_more
10000_merge_0054_usage_tracking
```

The existing `9999_usage_tracking_fork` migration remains recorded and is not
run again.

## Verify

```bash
docker compose exec linkding python manage.py check
docker compose exec linkding python manage.py migrate --plan
```

The migration plan should report no planned operations. In the UI:

1. Open General Settings and confirm usage tracking remains enabled if it was
   enabled before the upgrade.
2. Open a bookmark and confirm it redirects normally.
3. Select **Most Used** and confirm the existing order is retained.

## Roll Back

If verification fails, stop the service, restore the backup, restore the
previous image tag in Compose, and recreate the service:

```bash
docker compose stop linkding
cp /path/to/db.sqlite3.TIMESTAMP.bak /path/to/linkding/data/db.sqlite3
docker compose up -d linkding
```
