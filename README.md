# netbox-k8s
Setup for netbox in k8s with cloudnativepg for database

## Entra ID SSO

The NetBox Helm values use the tenant-specific v2 Entra ID backend and expect a
Secret named `entra-id-client` in the `netbox` namespace. Create it without
committing the client secret:

```sh
kubectl -n netbox create secret generic entra-id-client \
	--from-file=entra-id.yaml=/path/to/entra-id.yaml \
	--dry-run=client -o yaml | kubectl apply -f -
```

The file supplied to `--from-file` must contain:

```yaml
SOCIAL_AUTH_AZUREAD_V2_TENANT_OAUTH2_KEY: <APPLICATION_CLIENT_ID>
SOCIAL_AUTH_AZUREAD_V2_TENANT_OAUTH2_SECRET: <CLIENT_SECRET_VALUE>
SOCIAL_AUTH_AZUREAD_V2_TENANT_OAUTH2_TENANT_ID: <DIRECTORY_TENANT_ID>
```

Register this redirect URI in the Entra app registration:

`https://ipam.sj-tech.se/complete/azuread-v2-tenant-oauth2/`

Rotate the client secret that was previously present in `k8s/netbox.yaml`, then
sync the Argo CD application after creating the replacement Secret.
