# NeSI Observability Platform Integration

This document outlines the implementation for forwarding Prometheus metrics and logs to NeSI's observability platform (Mimir and Loki).

## Overview

This implementation adds:
- **Prometheus Remote Write** to Mimir: `https://mimir.observability.flexi.nesi.org.nz/api/v1/push`
- **Log Forwarding** to Loki: `https://loki.observability.flexi.nesi.org.nz/loki/api/v1/push`

## Architecture

The solution uses a dual-output approach:
- **Prometheus**: Continues local storage + remote write to Mimir
- **Logs**: Filebeat → OpenSearch (existing) + Promtail → Loki (new)

## Files Created/Modified

### Site-specific Configuration (shared across all environments)
- `environments/site/inventory/group_vars/all/prometheus_external.yml` - Remote write config
- `environments/site/inventory/group_vars/all/promtail.yml` - Promtail configuration
- `environments/site/files/filebeat/filebeat_external.yml` - Enhanced Filebeat config with cluster labels

### Environment-Specific Overrides (per environment)
- `environments/{env}/inventory/group_vars/all/external_integration.yml` - Enable/disable NeSI integration per environment
- `environments/{env}/inventory/group_vars/all/vault_external.yml` - Encrypted credentials (template)

## Implementation Steps

### 1. Obtain Credentials from NeSI

Contact NeSI to obtain:
- Mimir username/password for metrics
- Loki username/password for logs

### 2. Configure Credentials

```bash
# Edit the vault file with your actual credentials
ansible-vault edit $APPLIANCES_ENVIRONMENT_ROOT/inventory/group_vars/all/vault_external.yml

# Or encrypt the template file after adding credentials
ansible-vault encrypt $APPLIANCES_ENVIRONMENT_ROOT/inventory/group_vars/all/vault_external.yml
```

### 3. Test Connectivity

Before deployment, test the endpoints:

```bash
# Test Mimir endpoint
curl -u "username:password" -X POST "https://mimir.observability.flexi.nesi.org.nz/api/v1/push"

# Test Loki endpoint
curl -u "username:password" -X POST "https://loki.observability.flexi.nesi.org.nz/loki/api/v1/push"
```

### 4. Enable Integration Per Environment

The integration is controlled per environment via the `external_integration_enabled`
flag in `environments/{env}/inventory/group_vars/all/external_integration.yml`.

### 5. Deploy Configuration

```shell
ansible-playbook ansible/monitoring.yml --tags prometheus,filebeat
```
and deploy promtail (you may need to create a promtail role and hook it)

```shell
TODO
```

## Validation

### Metrics Validation (Mimir)

Use these queries in Grafana or directly against the Prometheus API:

```promql
# Check if node metrics are flowing to Mimir
up{cluster="slurm-cluster"}

# Check if Slurm exporter metrics are present
slurm_queue_jobs{cluster="slurm-cluster"}

# Verify CPU metrics from node exporter
node_cpu_seconds_total{cluster="slurm-cluster"}

# Check Prometheus remote write queue metrics (on local Prometheus)
prometheus_remote_storage_samples_pending
prometheus_remote_storage_samples_in_total
prometheus_remote_storage_samples_failed_total
```

### Log Validation (Loki)

Use these queries in Grafana's Loki data source:

```logql
# Check if slurm-stats logs are flowing
{cluster="slurm-cluster", job="slurm-stats"}

# Search for specific job completions
{cluster="slurm-cluster"} |= "JobID"

# Filter by specific user
{cluster="slurm-cluster", job="slurm-stats"} | json | user="specific_username"

# Check for completed jobs in the last hour
{cluster="slurm-cluster", job="slurm-stats"} | json | state="COMPLETED" | __error__=""
```

### Monitoring the Forwarding

Check these metrics on your local Prometheus:

```promql
# Remote write queue status
rate(prometheus_remote_storage_samples_total[5m])

# Remote write failures
rate(prometheus_remote_storage_samples_failed_total[5m])

# Promtail metrics (if exposed)
promtail_sent_entries_total
promtail_dropped_entries_total
```

## Troubleshooting

### Prometheus Remote Write Issues

1. Check Prometheus logs for remote write errors
2. Verify credentials in vault file
3. Check network connectivity to Mimir endpoint
4. Monitor `prometheus_remote_storage_*` metrics

### Log Forwarding Issues

1. Check Promtail logs: `journalctl -u promtail -f`
2. Verify log file paths are accessible
3. Check Loki endpoint connectivity
4. Verify credentials for Loki access

### Common Issues

- **Authentication failures**: Double-check credentials with NeSI
- **Network timeouts**: Verify firewall rules and network connectivity
- **High cardinality**: Be careful with label selection in Promtail config
- **Retention policies**: Understand NeSI's data retention policies

## Migration Strategy

### Phase 1: Parallel Operation (Current Implementation)
- Local Prometheus and OpenSearch continue running
- Remote write to Mimir and log forwarding to Loki added
- Run both systems in parallel for validation (2-4 weeks)

### Phase 2: Gradual Migration
Uncomment these lines in `prometheus.yml` after validation:
```yaml
prometheus_storage_retention: "7d"
prometheus_storage_retention_size: "20GB"
```

### Phase 3: Full Migration (Optional)
- Update Grafana dashboards to use remote data sources
- Consider disabling local storage for metrics (keep minimal for emergencies)

## Disabling Integration

To disable NeSI integration for a specific environment:

```bash
# Edit the environment-specific integration file
ansible-vault edit environments/{env}/inventory/group_vars/all/external_integration.yml

# Set external_integration_enabled to false
external_integration_enabled: false

# Redeploy
ansible-playbook -i inventory ../../ansible/monitoring.yml --tags prometheus,filebeat --ask-vault-pass
```

## Rollback Procedure

For emergency rollback:

1. Disable integration using the method above
2. Or manually remove remote_write section and revert filebeat config
3. Disable Promtail service if deployed
4. Redeploy with ansible-playbook

```bash
# Quick rollback by disabling integration
ansible-playbook -i inventory ../../ansible/monitoring.yml --tags prometheus,filebeat --ask-vault-pass
```

## Security Considerations

- Credentials are stored in Ansible Vault (encrypted)
- Basic auth used for API access
- Network traffic should be HTTPS only
- Regular credential rotation recommended
- Monitor for failed authentication attempts

## Performance Impact

- Remote write adds minimal CPU/memory overhead
- Network bandwidth: ~1-5% increase depending on metrics volume  
- Local storage: Can be reduced after successful migration
- Promtail: Lightweight agent with minimal resource usage
