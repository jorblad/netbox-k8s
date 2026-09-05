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

The file supplied to `--from-file` must be named `entra-id.yaml` and contain:

```yaml
SOCIAL_AUTH_AZUREAD_V2_TENANT_OAUTH2_KEY: <APPLICATION_CLIENT_ID>
SOCIAL_AUTH_AZUREAD_V2_TENANT_OAUTH2_SECRET: <CLIENT_SECRET_VALUE>
SOCIAL_AUTH_AZUREAD_V2_TENANT_OAUTH2_TENANT_ID: <DIRECTORY_TENANT_ID>
```

The Secret data key must be `entra-id.yaml`, not the individual
`SOCIAL_AUTH_*` setting names. The chart mounts Secret keys as files, and NetBox
only loads YAML files from the extra configuration directory. Replace a Secret
whose keys are individual settings with:

```sh
kubectl -n netbox delete secret entra-id-client
kubectl -n netbox create secret generic entra-id-client \
	--from-file=entra-id.yaml=/path/to/entra-id.yaml
```

You can also apply a Secret manifest. Save this as a local file such as
`entra-id-client.secret.yaml`, and do not commit it:

```yaml
apiVersion: v1
kind: Secret
metadata:
	name: entra-id-client
	namespace: netbox
type: Opaque
stringData:
	entra-id.yaml: |
		SOCIAL_AUTH_AZUREAD_V2_TENANT_OAUTH2_KEY: <APPLICATION_CLIENT_ID>
		SOCIAL_AUTH_AZUREAD_V2_TENANT_OAUTH2_SECRET: <CLIENT_SECRET_VALUE>
		SOCIAL_AUTH_AZUREAD_V2_TENANT_OAUTH2_TENANT_ID: <DIRECTORY_TENANT_ID>
```

Apply it with:

```sh
kubectl apply -f entra-id-client.secret.yaml
```

Do not use `data` with the settings as individual keys. If using `data`, the
single `entra-id.yaml` value must contain base64-encoded YAML. `stringData` is
simpler because Kubernetes performs that encoding during the apply.

Register this redirect URI in the Entra app registration:

`https://ipam.sj-tech.se/complete/azuread-v2-tenant-oauth2/`

Rotate the client secret that was previously present in `k8s/netbox.yaml`, then
sync the Argo CD application after creating the replacement Secret.
