# Edge Case Testing Plan

This document provides a structured testing plan for verifying edge case fixes related to interfaces, ports, bindings, and host consolidation.

## Prerequisites

Before running tests, you need:

1. **Session Cookie**: A valid session cookie for API authentication
2. **Daemon API Key**: A daemon key for discovery endpoint testing
3. **Network ID**: An existing network UUID to create entities in
4. **Base URL**: The API base URL (e.g., `http://localhost:3000`)

### Authentication

All API calls except discovery endpoints use cookie authentication:
```
Cookie: session=<your-session-cookie>
```

Discovery endpoints use the daemon API key:
```
X-API-Key: <your-daemon-api-key>
```

---

## Test Execution Instructions

For each test:
1. Execute the API calls in order
2. Verify the expected results
3. Record PASS/FAIL and any notes
4. Use unique entity names to ensure that test results can be manually verified

---

## Test Suite

### Test 1: Binding Conflict Validation

#### Test 1.1: Interface + Port Binding Conflict on Same Interface

**Purpose**: Verify that creating a service with both an interface binding AND a port binding on the same interface is rejected.

**Setup**:
```
POST /api/hosts
Content-Type: application/json

{
  "name": "Test Host 1.1",
  "network_id": "<NETWORK_ID>",
  "interfaces": [
    {
      "subnet_id": "<SUBNET_ID>",
      "ip_address": "10.0.0.101"
    }
  ],
  "ports": [
    {
      "number": 80,
      "protocol": "Tcp"
    }
  ],
  "tags": []
}
```

**Save from response**: `host_id`, `interface_id`, `port_id`

**Test**:
```
POST /api/services
Content-Type: application/json

{
  "id": "00000000-0000-0000-0000-000000000000",
  "created_at": "2025-01-01T00:00:00Z",
  "updated_at": "2025-01-01T00:00:00Z",
  "base": {
    "name": "Conflicting Service",
    "host_id": "<HOST_ID>",
    "network_id": "<NETWORK_ID>",
    "service_definition": {
      "id": "Web Server",
      "name": "Web Server",
      "category": "Web",
      "icon": "globe",
      "default_ports": []
    },
    "bindings": [
      {
        "id": "00000000-0000-0000-0000-000000000001",
        "created_at": "2025-01-01T00:00:00Z",
        "updated_at": "2025-01-01T00:00:00Z",
        "base": {
          "binding_type": {
            "type": "Interface",
            "interface_id": "<INTERFACE_ID>"
          }
        }
      },
      {
        "id": "00000000-0000-0000-0000-000000000002",
        "created_at": "2025-01-01T00:00:00Z",
        "updated_at": "2025-01-01T00:00:00Z",
        "base": {
          "binding_type": {
            "type": "Port",
            "port_id": "<PORT_ID>",
            "interface_id": "<INTERFACE_ID>"
          }
        }
      }
    ],
    "virtualization": null,
    "source": { "type": "Manual" },
    "tags": []
  }
}
```

**Expected Result**:
- Status: `400 Bad Request`
- Error message contains: "interface binding" and "port binding" conflict

**Cleanup**:
```
DELETE /api/hosts/<HOST_ID>
```

---

#### Test 1.2: All-Interfaces Port Conflicts with Interface Binding

**Purpose**: Verify that a port binding on "all interfaces" conflicts with an interface binding.

**Setup**: Create host with interface and port (same as 1.1)

**Test**:
```
POST /api/services
Content-Type: application/json

{
  "id": "00000000-0000-0000-0000-000000000000",
  "created_at": "2025-01-01T00:00:00Z",
  "updated_at": "2025-01-01T00:00:00Z",
  "base": {
    "name": "All-Interfaces Conflict Service",
    "host_id": "<HOST_ID>",
    "network_id": "<NETWORK_ID>",
    "service_definition": {
      "id": "Web Server",
      "name": "Web Server",
      "category": "Web",
      "icon": "globe",
      "default_ports": []
    },
    "bindings": [
      {
        "id": "00000000-0000-0000-0000-000000000001",
        "created_at": "2025-01-01T00:00:00Z",
        "updated_at": "2025-01-01T00:00:00Z",
        "base": {
          "binding_type": {
            "type": "Interface",
            "interface_id": "<INTERFACE_ID>"
          }
        }
      },
      {
        "id": "00000000-0000-0000-0000-000000000002",
        "created_at": "2025-01-01T00:00:00Z",
        "updated_at": "2025-01-01T00:00:00Z",
        "base": {
          "binding_type": {
            "type": "Port",
            "port_id": "<PORT_ID>",
            "interface_id": null
          }
        }
      }
    ],
    "virtualization": null,
    "source": { "type": "Manual" },
    "tags": []
  }
}
```

**Expected Result**:
- Status: `400 Bad Request`
- Error message indicates all-interfaces port binding conflicts with interface binding

**Cleanup**: Delete host

---

#### Test 1.3: Valid Non-Conflicting Bindings (Different Interfaces)

**Purpose**: Verify that bindings on different interfaces don't conflict.

**Setup**:
```
POST /api/hosts
Content-Type: application/json

{
  "name": "Test Host 1.3",
  "network_id": "<NETWORK_ID>",
  "interfaces": [
    {
      "subnet_id": "<SUBNET_ID>",
      "ip_address": "10.0.0.102"
    },
    {
      "subnet_id": "<SUBNET_ID>",
      "ip_address": "10.0.0.103"
    }
  ],
  "ports": [
    {
      "number": 80,
      "protocol": "Tcp"
    }
  ],
  "tags": []
}
```

**Save**: `host_id`, `interface_id_A` (first), `interface_id_B` (second), `port_id`

**Test**:
```
POST /api/services
Content-Type: application/json

{
  "id": "00000000-0000-0000-0000-000000000000",
  "created_at": "2025-01-01T00:00:00Z",
  "updated_at": "2025-01-01T00:00:00Z",
  "base": {
    "name": "Non-Conflicting Service",
    "host_id": "<HOST_ID>",
    "network_id": "<NETWORK_ID>",
    "service_definition": {
      "id": "Web Server",
      "name": "Web Server",
      "category": "Web",
      "icon": "globe",
      "default_ports": []
    },
    "bindings": [
      {
        "id": "00000000-0000-0000-0000-000000000001",
        "created_at": "2025-01-01T00:00:00Z",
        "updated_at": "2025-01-01T00:00:00Z",
        "base": {
          "binding_type": {
            "type": "Interface",
            "interface_id": "<INTERFACE_ID_A>"
          }
        }
      },
      {
        "id": "00000000-0000-0000-0000-000000000002",
        "created_at": "2025-01-01T00:00:00Z",
        "updated_at": "2025-01-01T00:00:00Z",
        "base": {
          "binding_type": {
            "type": "Port",
            "port_id": "<PORT_ID>",
            "interface_id": "<INTERFACE_ID_B>"
          }
        }
      }
    ],
    "virtualization": null,
    "source": { "type": "Manual" },
    "tags": []
  }
}
```

**Expected Result**:
- Status: `201 Created`
- Service created successfully with both bindings

**Cleanup**: Delete host

---

### Test 2: Optimistic Locking

#### Test 2.1: Concurrent Modification Detection

**Purpose**: Verify that updates with stale `expected_updated_at` are rejected.

**Setup**:
```
POST /api/hosts
Content-Type: application/json

{
  "name": "Test Host 2.1",
  "network_id": "<NETWORK_ID>",
  "interfaces": [],
  "ports": [],
  "tags": []
}
```

**Save**: `host_id`, `original_updated_at`

**Step 1 - Simulate concurrent modification**:
```
PUT /api/hosts/<HOST_ID>
Content-Type: application/json

{
  "id": "<HOST_ID>",
  "name": "Test Host 2.1 - Modified by discovery",
  "hostname": null,
  "description": null,
  "virtualization": null,
  "hidden": false,
  "tags": []
}
```

This updates the host and changes `updated_at`.

**Step 2 - Attempt update with stale timestamp**:
```
PUT /api/hosts/<HOST_ID>
Content-Type: application/json

{
  "id": "<HOST_ID>",
  "name": "Test Host 2.1 - User edit",
  "hostname": null,
  "description": null,
  "virtualization": null,
  "hidden": false,
  "tags": [],
  "expected_updated_at": "<ORIGINAL_UPDATED_AT>"
}
```

**Expected Result**:
- Status: `400 Bad Request` or `409 Conflict`
- Error message contains: "modified by another process"

**Cleanup**: Delete host

---

#### Test 2.2: Valid Update with Matching Timestamp

**Purpose**: Verify updates succeed when `expected_updated_at` matches.

**Setup**: Create host, save `host_id` and `updated_at`

**Test**:
```
PUT /api/hosts/<HOST_ID>
Content-Type: application/json

{
  "id": "<HOST_ID>",
  "name": "Test Host 2.2 - Valid Update",
  "hostname": null,
  "description": null,
  "virtualization": null,
  "hidden": false,
  "tags": [],
  "expected_updated_at": "<UPDATED_AT>"
}
```

**Expected Result**:
- Status: `200 OK`
- Host updated successfully
- Response `updated_at` is different from the original

**Cleanup**: Delete host

---

#### Test 2.3: Update Without Optimistic Locking (Backward Compatibility)

**Purpose**: Verify updates work when `expected_updated_at` is omitted.

**Setup**: Create host

**Test**:
```
PUT /api/hosts/<HOST_ID>
Content-Type: application/json

{
  "id": "<HOST_ID>",
  "name": "Test Host 2.3 - No Locking",
  "hostname": null,
  "description": null,
  "virtualization": null,
  "hidden": false,
  "tags": []
}
```

**Expected Result**:
- Status: `200 OK`
- Update succeeds (field is optional)

**Cleanup**: Delete host

---

### Test 3: All-Interfaces Replaces Specific Bindings

#### Test 3.1: Discovery Upsert Replaces Specific with All-Interfaces

**Purpose**: Verify that when discovery reports a port binding on all-interfaces, it replaces existing specific interface bindings.

**Setup**:
```
# Create host with interface and port
POST /api/hosts
{
  "name": "Test Host 3.1",
  "network_id": "<NETWORK_ID>",
  "interfaces": [{"subnet_id": "<SUBNET_ID>", "ip_address": "10.0.0.110"}],
  "ports": [{"number": 443, "protocol": "Tcp"}],
  "tags": []
}
```

**Save**: `host_id`, `interface_id`, `port_id`

```
# Create service with port binding on specific interface
POST /api/services
{
  "id": "00000000-0000-0000-0000-000000000000",
  "created_at": "2025-01-01T00:00:00Z",
  "updated_at": "2025-01-01T00:00:00Z",
  "base": {
    "name": "HTTPS Service",
    "host_id": "<HOST_ID>",
    "network_id": "<NETWORK_ID>",
    "service_definition": {"id": "Web Server", "name": "Web Server", "category": "Web", "icon": "globe", "default_ports": []},
    "bindings": [{
      "id": "00000000-0000-0000-0000-000000000001",
      "created_at": "2025-01-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z",
      "base": {
        "binding_type": {
          "type": "Port",
          "port_id": "<PORT_ID>",
          "interface_id": "<INTERFACE_ID>"
        }
      }
    }],
    "virtualization": null,
    "source": {"type": "Manual"},
    "tags": []
  }
}
```

**Save**: `service_id`

**Test - Discovery upsert with all-interfaces binding**:
```
POST /api/discovery/hosts
X-API-Key: <DAEMON_API_KEY>
Content-Type: application/json

{
  "host": {
    "id": "<HOST_ID>",
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-01T00:00:00Z",
    "base": {
      "name": "Test Host 3.1",
      "network_id": "<NETWORK_ID>",
      "hostname": null,
      "description": null,
      "source": {"type": "Discovery", "metadata": [{"daemon_id": "<DAEMON_ID>", "timestamp": "2025-01-01T00:00:00Z"}]},
      "virtualization": null,
      "hidden": false,
      "tags": []
    }
  },
  "interfaces": [{
    "id": "<INTERFACE_ID>",
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-01T00:00:00Z",
    "base": {
      "network_id": "<NETWORK_ID>",
      "host_id": "<HOST_ID>",
      "subnet_id": "<SUBNET_ID>",
      "ip_address": "10.0.0.110",
      "mac_address": null,
      "name": null
    }
  }],
  "ports": [{
    "id": "<PORT_ID>",
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-01T00:00:00Z",
    "base": {
      "host_id": "<HOST_ID>",
      "network_id": "<NETWORK_ID>",
      "port_type": {"type": "Custom", "number": 443, "protocol": "Tcp"}
    }
  }],
  "services": [{
    "id": "<SERVICE_ID>",
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-01T00:00:00Z",
    "base": {
      "name": "HTTPS Service",
      "host_id": "<HOST_ID>",
      "network_id": "<NETWORK_ID>",
      "service_definition": {"id": "Web Server", "name": "Web Server", "category": "Web", "icon": "globe", "default_ports": []},
      "bindings": [{
        "id": "00000000-0000-0000-0000-000000000099",
        "created_at": "2025-01-01T00:00:00Z",
        "updated_at": "2025-01-01T00:00:00Z",
        "base": {
          "binding_type": {
            "type": "Port",
            "port_id": "<PORT_ID>",
            "interface_id": null
          }
        }
      }],
      "virtualization": null,
      "source": {"type": "Discovery", "metadata": []},
      "tags": []
    }
  }]
}
```

**Verification**:
```
GET /api/services/<SERVICE_ID>
```

**Expected Result**:
- Service has exactly ONE port binding
- That binding has `interface_id: null` (all-interfaces)
- The specific interface binding was replaced

**Cleanup**: Delete host

---

#### Test 3.2: Specific Binding Skipped When All-Interfaces Exists

**Purpose**: Verify discovery doesn't add redundant specific binding when all-interfaces already exists.

**Setup**: Create host, port, and service with all-interfaces binding (interface_id: null)

**Test**: Discovery upsert with same service but specific interface binding

**Expected Result**:
- Service still has only all-interfaces binding
- Specific binding was not added (redundant)

**Cleanup**: Delete host

---

### Test 4: Host Consolidation

#### Test 4.1: Basic Consolidation Success

**Purpose**: Verify basic host consolidation works.

**Setup**:
```
# Create destination host
POST /api/hosts
{
  "name": "Destination Host",
  "network_id": "<NETWORK_ID>",
  "interfaces": [{"subnet_id": "<SUBNET_ID>", "ip_address": "10.0.0.120"}],
  "ports": [],
  "tags": []
}
```
**Save**: `dest_host_id`

```
# Create source host with service
POST /api/hosts
{
  "name": "Source Host",
  "network_id": "<NETWORK_ID>",
  "interfaces": [{"subnet_id": "<SUBNET_ID>", "ip_address": "10.0.0.121"}],
  "ports": [{"number": 22, "protocol": "Tcp"}],
  "tags": []
}
```
**Save**: `source_host_id`, `source_interface_id`, `source_port_id`

```
# Create service on source host
POST /api/services
{
  "id": "00000000-0000-0000-0000-000000000000",
  "created_at": "2025-01-01T00:00:00Z",
  "updated_at": "2025-01-01T00:00:00Z",
  "base": {
    "name": "SSH Service",
    "host_id": "<SOURCE_HOST_ID>",
    "network_id": "<NETWORK_ID>",
    "service_definition": {"id": "SSH", "name": "SSH", "category": "Remote Access", "icon": "terminal", "default_ports": []},
    "bindings": [{
      "id": "00000000-0000-0000-0000-000000000001",
      "created_at": "2025-01-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z",
      "base": {
        "binding_type": {
          "type": "Port",
          "port_id": "<SOURCE_PORT_ID>",
          "interface_id": "<SOURCE_INTERFACE_ID>"
        }
      }
    }],
    "virtualization": null,
    "source": {"type": "Manual"},
    "tags": []
  }
}
```
**Save**: `service_id`

**Test - Consolidate**:
```
PUT /api/hosts/<DEST_HOST_ID>/consolidate/<SOURCE_HOST_ID>
```

**Expected Result**:
- Status: `200 OK`
- Source host is deleted
- Service is transferred to destination host
- Port binding falls back to all-interfaces (interface didn't match)
- Check server logs for warning about fallback

**Verification**:
```
GET /api/hosts/<DEST_HOST_ID>
```
- Should include the SSH service
- Service binding should have `interface_id: null`

```
GET /api/hosts/<SOURCE_HOST_ID>
```
- Should return `404 Not Found`

**Cleanup**: Delete destination host

---

#### Test 4.2: Consolidation with Duplicate Services

**Purpose**: Verify duplicate services are handled correctly during consolidation.

**Setup**:
```
# Create destination host with DNS service
POST /api/hosts {...}
POST /api/services {name: "DNS Server", host_id: dest_host_id, ...}

# Create source host with same DNS service
POST /api/hosts {...}
POST /api/services {name: "DNS Server", host_id: source_host_id, ...}
```

**Test**:
```
PUT /api/hosts/<DEST_HOST_ID>/consolidate/<SOURCE_HOST_ID>
```

**Expected Result**:
- Status: `200 OK`
- Destination host has only ONE DNS Server service (not duplicated)
- Check server logs for warning about skipped duplicate

**Cleanup**: Delete destination host

---

#### Test 4.3: Consolidation - Interface Binding Dropped with Warning

**Purpose**: Verify interface bindings are dropped (with warning) when interface doesn't match.

**Setup**:
```
# Destination host with interface A
POST /api/hosts {interfaces: [{ip: "10.0.0.130"}], ...}

# Source host with interface B and service with INTERFACE binding (not port)
POST /api/hosts {interfaces: [{ip: "10.0.0.131"}], ...}
POST /api/services {bindings: [{type: "Interface", interface_id: B}], ...}
```

**Test**:
```
PUT /api/hosts/<DEST_HOST_ID>/consolidate/<SOURCE_HOST_ID>
```

**Expected Result**:
- Status: `200 OK`
- Service transferred but has NO bindings (interface binding dropped)
- Check server logs for warning: "Dropping interface binding during reassignment"

**Cleanup**: Delete hosts

---

### Test 5: Edge Case - Binding Validation on Existing Data

#### Test 5.1: Update Service with Pre-existing Conflicting Bindings

**Purpose**: Verify that services with pre-existing "invalid" binding combinations can still be updated.

**Note**: This tests backward compatibility if old data exists before validation was added.

**Setup**:
1. Temporarily disable validation (or use direct DB insert)
2. Create service with conflicting bindings
3. Re-enable validation

**Test**:
```
PUT /api/services/<SERVICE_ID>
{
  ... update name only, keep existing bindings ...
}
```

**Expected Result**:
- Ideally: Update succeeds for non-binding fields
- Or: Clear error message about existing conflicts

---

### Test 6: Race Condition Simulation

#### Test 6.1: Rapid Sequential Updates

**Purpose**: Verify rapid updates work when each uses fresh `updated_at`.

**Setup**: Create host

**Test**:
```
# Update 1
GET /api/hosts/<HOST_ID>  -> save updated_at_1
PUT /api/hosts/<HOST_ID> {expected_updated_at: updated_at_1, name: "Update 1"}

# Update 2 (immediately after)
GET /api/hosts/<HOST_ID>  -> save updated_at_2
PUT /api/hosts/<HOST_ID> {expected_updated_at: updated_at_2, name: "Update 2"}

# Update 3 (immediately after)
GET /api/hosts/<HOST_ID>  -> save updated_at_3
PUT /api/hosts/<HOST_ID> {expected_updated_at: updated_at_3, name: "Update 3"}
```

**Expected Result**:
- All three updates succeed
- Final name is "Update 3"

**Cleanup**: Delete host

---

## Summary Checklist

| Test | Description | Status |
|------|-------------|--------|
| 1.1 | Interface + Port binding conflict rejected | |
| 1.2 | All-interfaces port conflicts with interface binding | |
| 1.3 | Valid non-conflicting bindings succeed | |
| 2.1 | Stale timestamp rejected | |
| 2.2 | Matching timestamp succeeds | |
| 2.3 | Missing timestamp succeeds (backward compat) | |
| 3.1 | All-interfaces replaces specific binding | |
| 3.2 | Specific binding skipped when all-interfaces exists | |
| 4.1 | Basic consolidation with binding fallback | |
| 4.2 | Duplicate services handled in consolidation | |
| 4.3 | Interface binding dropped with warning | |
| 5.1 | Legacy conflicting data still updatable | |
| 6.1 | Rapid sequential updates succeed | |

---

## Notes for Test Executor

1. **Generate UUIDs**: Use real UUIDs (e.g., `uuidgen` command) for entity IDs
2. **Timestamps**: Use current ISO 8601 timestamps
3. **Check Logs**: Several tests require checking server logs for warnings
4. **Order Matters**: Run tests in order; some depend on understanding from earlier tests
5. **Clean State**: Delete all test entities between tests to avoid interference
6. **Network/Subnet**: You need a valid network and subnet ID that allows the test IP addresses
