# Edge Case Testing Plan v5: Permissions, Tags, and Daemons

This plan covers high-priority gaps not addressed in v1-v4.

## Prerequisites
- Access to multiple user accounts with different permission levels
- At least 2 networks in an organization
- API key for daemon testing

---

## 1. Permission/Access Control

### Test 1.1: User Without Network Access Attempts Read
**Setup:** User A has access to Network 1 only. Network 2 exists with hosts.
**Action:** User A attempts `GET /api/hosts` filtered to Network 2, or `GET /api/hosts/{network2_host_id}`
**Expected:** 404 Not Found (not 403, to avoid leaking existence)

| Result | Notes |
|--------|-------|
| | |

### Test 1.2: User Without Network Access Attempts Create
**Setup:** User A has access to Network 1 only.
**Action:** User A attempts `POST /api/hosts` with `network_id` = Network 2
**Expected:** 400 or 403 error indicating no access to that network

| Result | Notes |
|--------|-------|
| | |

### Test 1.3: User Without Network Access Attempts Update
**Setup:** User A has access to Network 1 only. Host exists on Network 2.
**Action:** User A attempts `PUT /api/hosts/{network2_host_id}`
**Expected:** 404 Not Found

| Result | Notes |
|--------|-------|
| | |

### Test 1.4: User Without Network Access Attempts Delete
**Setup:** User A has access to Network 1 only. Host exists on Network 2.
**Action:** User A attempts `DELETE /api/hosts/{network2_host_id}`
**Expected:** 404 Not Found

| Result | Notes |
|--------|-------|
| | |

### Test 1.5: User Attempts Cross-Network Consolidation
**Setup:** User A has access to Network 1 only. Both hosts exist but one is on Network 2.
**Action:** User A attempts `PUT /api/hosts/{net1_host}/consolidate/{net2_host}`
**Expected:** 404 for the inaccessible host

| Result | Notes |
|--------|-------|
| | |

### Test 1.6: User Bulk Delete Mixed Access
**Setup:** User A has access to Network 1 only. Mix of host IDs from Network 1 and Network 2.
**Action:** User A attempts `POST /api/hosts/bulk-delete` with mixed IDs
**Expected:** Only Network 1 hosts deleted, or error if strict validation

| Result | Notes |
|--------|-------|
| | |

### Test 1.7: Cross-Organization Access Attempt
**Setup:** User A in Org 1, User B in Org 2. Host exists in Org 2.
**Action:** User A attempts to access/modify Org 2 resources
**Expected:** 404 Not Found (resource invisible to other orgs)

| Result | Notes |
|--------|-------|
| | |

---

## 2. Tag Operations

### Test 2.1: Create Tag with Duplicate Name
**Setup:** Tag "Production" exists in organization.
**Action:** Create another tag with name "Production" in same org
**Expected:** 400 error indicating duplicate name

| Result | Notes |
|--------|-------|
| | |

### Test 2.2: Create Tag with Same Name in Different Org
**Setup:** Tag "Production" exists in Org 1.
**Action:** Create tag "Production" in Org 2
**Expected:** Success (tags are org-scoped)

| Result | Notes |
|--------|-------|
| | |

### Test 2.3: Delete Tag Referenced by Host
**Setup:** Tag "Critical" assigned to multiple hosts.
**Action:** Delete the tag
**Expected:** Success - tag removed from all hosts, hosts remain

| Result | Notes |
|--------|-------|
| | |

### Test 2.4: Delete Tag Referenced by Multiple Entity Types
**Setup:** Tag assigned to hosts, services, subnets, and groups.
**Action:** Delete the tag
**Expected:** Success - tag removed from all entities

| Result | Notes |
|--------|-------|
| | |

### Test 2.5: Update Tag Name to Existing Name
**Setup:** Tags "Production" and "Staging" exist.
**Action:** Rename "Staging" to "Production"
**Expected:** 400 error indicating duplicate name

| Result | Notes |
|--------|-------|
| | |

### Test 2.6: Assign Non-Existent Tag to Entity
**Setup:** Host exists, random UUID for tag.
**Action:** Update host with non-existent tag UUID in tags array
**Expected:** 400 error or tag silently ignored (document actual behavior)

| Result | Notes |
|--------|-------|
| | |

### Test 2.7: Assign Tag from Different Organization
**Setup:** Tag exists in Org 1, Host exists in Org 2.
**Action:** Update host with tag UUID from different org
**Expected:** 400 error (tag not found in org) or silently ignored

| Result | Notes |
|--------|-------|
| | |

### Test 2.8: Assign Same Tag Multiple Times
**Setup:** Host with tag "Production".
**Action:** Update host with tags array containing "Production" UUID twice
**Expected:** Success with deduplication (tag appears once)

| Result | Notes |
|--------|-------|
| | |

### Test 2.9: Tag Name Edge Cases
**Action:** Create tags with:
- Empty string name
- Very long name (500+ chars)
- Unicode characters
- Special characters (quotes, slashes, etc.)

**Expected:**
- Empty: 400 error
- Long: 400 error (if limit exists) or truncation
- Unicode: Success
- Special chars: Success

| Case | Result | Notes |
|------|--------|-------|
| Empty | | |
| Long | | |
| Unicode | | |
| Special | | |

---

## 3. API Keys

### Test 3.1: Create API Key
**Action:** `POST /api/api-keys` with name
**Expected:** Returns new API key with key value (only shown once)

| Result | Notes |
|--------|-------|
| | |

### Test 3.2: List API Keys Doesn't Expose Key Value
**Action:** `GET /api/api-keys`
**Expected:** List of keys without the actual key values (or masked)

| Result | Notes |
|--------|-------|
| | |

### Test 3.3: Use API Key for Authentication
**Setup:** Create API key for user.
**Action:** Make request with `Authorization: Bearer {api_key}`
**Expected:** Request authenticated as the key's user

| Result | Notes |
|--------|-------|
| | |

### Test 3.4: Delete API Key Revokes Access
**Setup:** Create API key, verify it works.
**Action:** Delete the API key, then try to use it
**Expected:** 401 Unauthorized after deletion

| Result | Notes |
|--------|-------|
| | |

### Test 3.5: API Key Scoped to Organization
**Setup:** API key for Org 1 user.
**Action:** Try to access Org 2 resources with the key
**Expected:** 404 (resources invisible) or 403

| Result | Notes |
|--------|-------|
| | |

---

## 4. Daemon Lifecycle

### Test 4.1: Create Daemon on Host
**Action:** Create daemon assigned to a host and network
**Expected:** Success, daemon associated with host

| Result | Notes |
|--------|-------|
| | |

### Test 4.2: Delete Host with Daemon
**Setup:** Host has associated daemon.
**Action:** `DELETE /api/hosts/{id}`
**Expected:** 409 Conflict - must delete daemon first

| Result | Notes |
|--------|-------|
| | |

### Test 4.3: Delete Daemon Then Host
**Setup:** Host has associated daemon.
**Action:** Delete daemon, then delete host
**Expected:** Both operations succeed

| Result | Notes |
|--------|-------|
| | |

### Test 4.4: Daemon Discovery on Wrong Network
**Setup:** Daemon assigned to Network 1.
**Action:** Daemon sends discovery data for host on Network 2
**Expected:** 403 error - daemon can only discover on its network

| Result | Notes |
|--------|-------|
| | |

### Test 4.5: Daemon Creates Subnet on Wrong Network
**Setup:** Daemon assigned to Network 1.
**Action:** Daemon attempts `POST /api/subnets` with network_id = Network 2
**Expected:** 400 error

| Result | Notes |
|--------|-------|
| | |

### Test 4.6: Consolidate Host That Has Daemon (as destination)
**Setup:** Host A has daemon, Host B does not.
**Action:** Consolidate B into A (A is destination)
**Expected:** Success - daemon's host receives consolidated data

| Result | Notes |
|--------|-------|
| | |

### Test 4.7: Consolidate Host That Has Daemon (as source)
**Setup:** Host A has daemon, Host B does not.
**Action:** Consolidate A into B (A would be deleted)
**Expected:** 400 error - cannot consolidate host with daemon as source

| Result | Notes |
|--------|-------|
| | |

### Test 4.8: Bulk Delete Hosts Including One with Daemon
**Setup:** 3 hosts, one has daemon.
**Action:** Bulk delete all 3
**Expected:** 409 Conflict - none deleted due to daemon constraint

| Result | Notes |
|--------|-------|
| | |

### Test 4.9: Delete Network with Daemon
**Setup:** Network has host with daemon.
**Action:** Delete the network
**Expected:** 409 Conflict or cascade behavior (document actual)

| Result | Notes |
|--------|-------|
| | |

### Test 4.10: Update Daemon Network
**Setup:** Daemon on Network 1.
**Action:** Update daemon to be on Network 2
**Expected:** 400 error (network is immutable) or success with validation

| Result | Notes |
|--------|-------|
| | |

---

## Summary Checklist

| Section | Tests | Passed | Failed | Skipped |
|---------|-------|--------|--------|---------|
| 1. Permissions | 7 | | | |
| 2. Tags | 9 | | | |
| 3. API Keys | 5 | | | |
| 4. Daemons | 10 | | | |
| **Total** | **31** | | | |

## Bugs Found

| Test | Description | Severity | Status |
|------|-------------|----------|--------|
| | | | |
