# Network Plan

| Component | Address range | Purpose |
|---|---|---|
| Virtual network | 10.20.0.0/16 | Complete Azure network |
| Management subnet | 10.20.1.0/24 | Secure administration |
| Application subnet | 10.20.10.0/24 | Application workloads |
| Data subnet | 10.20.20.0/24 | Data resources |

## Traffic Rules

- Public RDP and SSH are denied.
- Management traffic is separated from application traffic.
- Application-to-data traffic is allowed only when required.
- Broad Any-to-Any rules are avoided.
- Network paths will be tested after deployment.