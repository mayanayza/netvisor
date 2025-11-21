# NetVisor Security Analysis Report

**Analysis Date:** 2025-11-21
**Analyzed Version:** Latest (branch: claude/add-usage-docs-01PTpkhQEmE51HeztziTU48B)
**Analysis Type:** Comprehensive security audit for backdoors and vulnerabilities

---

## Executive Summary

This report presents the findings of a comprehensive security analysis of the NetVisor project, focusing on identifying potential backdoors, security vulnerabilities, and configuration issues. The analysis examined authentication mechanisms, database operations, network communications, privilege management, and common vulnerability patterns.

**Overall Assessment:** ✅ **NO BACKDOORS DETECTED**

The codebase demonstrates strong security practices in most areas, with several notable security controls in place. However, some configuration concerns were identified that should be addressed.

---

## 🔍 Analysis Scope

The security audit covered the following areas:

1. **Backdoor Detection**
   - Hardcoded credentials and secrets
   - Hidden administrative accounts
   - Suspicious network communications
   - Unauthorized remote access mechanisms

2. **Vulnerability Assessment**
   - SQL Injection
   - Cross-Site Scripting (XSS)
   - Command Injection
   - Authentication and Authorization flaws
   - Session management issues

3. **Configuration Review**
   - CORS policies
   - Session cookies security
   - Privilege escalation risks
   - Docker security settings

---

## ✅ Security Strengths

### 1. Authentication & Password Security

**Location:** `backend/src/server/auth/`

**Findings:**
- ✅ **Strong password requirements** enforced:
  - Minimum 12 characters
  - Must contain uppercase, lowercase, numbers, and special characters
  - Validation code: `backend/src/server/auth/impl/api.rs:23-43`

- ✅ **Argon2id password hashing** (industry best practice)
  - Implementation: `backend/src/server/auth/service.rs:264-285`

- ✅ **Login rate limiting** implemented:
  - Maximum 5 failed attempts
  - 15-minute lockout period
  - Implementation: `backend/src/server/auth/service.rs:34-35`

### 2. SQL Injection Prevention

**Location:** `backend/src/server/shared/storage/generic.rs`

**Findings:**
- ✅ **Parameterized queries** used throughout
  - Uses sqlx with type-safe query binding
  - All user inputs properly sanitized
  - Implementation: `backend/src/server/shared/storage/generic.rs:55-96`

### 3. XSS Prevention

**Location:** `ui/` directory

**Findings:**
- ✅ **No dangerous HTML rendering** detected
  - No `dangerouslySetInnerHTML` usage found
  - No `innerHTML` manipulation detected
  - Framework-level XSS protection (Svelte)

### 4. Session Security

**Location:** `backend/src/server/shared/storage/factory.rs`

**Findings:**
- ✅ **Secure session configuration**:
  - HttpOnly cookies enabled: `factory.rs:41`
  - SameSite=Lax protection: `factory.rs:42`
  - 30-day session expiry on inactivity: `factory.rs:38`
  - Configurable secure flag for HTTPS: `factory.rs:40`

### 5. Authorization Controls

**Location:** `backend/src/server/auth/middleware.rs`

**Findings:**
- ✅ **Role-based access control** implemented:
  - User vs Daemon authentication separation
  - Permission levels: Owner, Admin, Member
  - API key authentication for daemons with expiration
  - Implementation: `backend/src/server/auth/middleware.rs`

### 6. Network Communications

**Findings:**
- ✅ **No suspicious external URLs** detected
- ✅ All HTTP requests go to legitimate services:
  - GitHub API: `api.github.com`
  - CDN services: `cdn.jsdelivr.net`, `simpleicons.org`, `vectorlogo.zone`
  - Local/internal services only

---

## ⚠️ Security Concerns & Recommendations

### 1. CORS Configuration - **MEDIUM SEVERITY**

**Location:** `backend/src/bin/server.rs:219-220`

**Issue:**
```rust
// Production: Same-origin, no CORS needed but keep it permissive for future flexibility
CorsLayer::permissive()
```

**Risk:**
The production CORS configuration uses `permissive()` which allows **any origin** to make requests. This could enable CSRF attacks and unauthorized cross-origin data access.

**Recommendation:**
```rust
// Restrict to same-origin or specific trusted origins only
CorsLayer::new()
    .allow_origin(Origin::exact("https://yourdomain.com".parse().unwrap()))
    .allow_credentials(true)
    .allow_methods([Method::GET, Method::POST, Method::PUT, Method::DELETE])
    .allow_headers([header::CONTENT_TYPE, header::AUTHORIZATION])
```

**Severity Justification:** While session cookies have SameSite=Lax protection, overly permissive CORS could still expose the API to certain attack vectors.

---

### 2. Docker Privileged Mode - **HIGH SEVERITY**

**Location:** `docker-compose.yml:11`

**Issue:**
```yaml
daemon:
  privileged: true
```

**Risk:**
Running containers with `privileged: true` grants **all capabilities** and removes security boundaries between the container and host. This is a significant security risk if the container is compromised.

**Why It's Used:**
The daemon requires host network access for network scanning capabilities, which typically requires elevated privileges.

**Recommendations:**

**Option 1 (Preferred): Use specific capabilities instead of privileged mode**
```yaml
daemon:
  cap_add:
    - NET_ADMIN
    - NET_RAW
    - SYS_ADMIN  # Only if absolutely necessary
  # Remove: privileged: true
```

**Option 2: Network namespace isolation**
Consider separating the privileged scanning functionality into a minimal, isolated component while keeping the main daemon unprivileged.

**Option 3: Document security implications**
If privileged mode is truly necessary, add prominent security warnings in documentation about:
- Running in isolated/trusted networks only
- Regular security updates
- Container image verification

**Impact:** If the daemon container is compromised, attackers could gain full host access.

---

### 3. Docker Socket Access - **MEDIUM SEVERITY**

**Location:** `docker-compose.yml:28`

**Issue:**
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock:ro
```

**Risk:**
Mounting the Docker socket (even read-only) allows the container to inspect all containers and potentially escalate privileges.

**Why It's Used:**
Required for Docker container discovery functionality.

**Recommendations:**
1. **Document security implications** in deployment guide
2. **Consider alternatives** like Docker API proxies with restricted permissions
3. **Implement least privilege** - ensure only discovery operations are performed
4. **Monitor access** - log all Docker socket interactions

---

### 4. Default PostgreSQL Password - **LOW SEVERITY**

**Location:** `docker-compose.yml:35`

**Issue:**
```yaml
POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-password}
```

**Risk:**
Default password "password" used if environment variable not set.

**Recommendation:**
1. Require explicit password configuration (no default)
2. Add setup documentation emphasizing strong password selection
3. Consider generating random password on first run

**Current Mitigation:** Database is isolated in internal Docker network, reducing external exposure.

---

### 5. Secure Cookie Configuration - **LOW SEVERITY**

**Location:** `backend/src/server/config.rs:101`

**Issue:**
```rust
use_secure_session_cookies: false  // default
```

**Risk:**
Cookies not marked as "secure" by default, allowing transmission over HTTP.

**Recommendation:**
Update documentation to prominently display:
```markdown
⚠️ **IMPORTANT**: When deploying with HTTPS, set:
NETVISOR_USE_SECURE_SESSION_COOKIES=true
```

**Current Mitigation:** Already documented in README.md line 209.

---

### 6. Command Execution in Docker Containers - **LOW SEVERITY**

**Location:** `backend/src/daemon/discovery/service/docker.rs:876-926`

**Issue:**
Docker exec commands are constructed using format strings with port numbers and paths.

**Current Implementation:**
```rust
format!("curl -i -s -m 1 -L --max-redirs 2 http://127.0.0.1:{}{}",
    container_port, path)
```

**Risk Assessment:**
- Port numbers come from internal service definitions (not user input)
- Paths are predefined in service discovery rules
- Executed only inside target containers (not host system)

**Current Status:** ✅ **Acceptable** - inputs are controlled and not user-supplied.

**Recommendation:**
Add code comments documenting that `container_port` and `path` come from trusted internal sources only.

---

## 🔒 No Backdoors Found

### Checked Patterns:
- ✅ No hardcoded API keys or credentials
- ✅ No hidden administrative accounts
- ✅ No suspicious outbound network connections
- ✅ No unauthorized data exfiltration code
- ✅ No hidden debug/development backdoors
- ✅ No eval() or dynamic code execution

### Unsafe Code Review:
Limited `unsafe` usage found only in platform-specific system calls:
- `backend/src/daemon/utils/windows.rs:46-64` - Windows ARP table access
- `backend/src/daemon/utils/linux.rs:30` - Linux resource limits
- `backend/src/daemon/utils/macos.rs:51` - macOS resource limits

**Assessment:** All unsafe code is justified and limited to OS-level operations.

---

## 📋 Summary of Findings

| Issue | Severity | Status | File |
|-------|----------|--------|------|
| CORS permissive in production | Medium | ⚠️ Needs fix | `backend/src/bin/server.rs:220` |
| Docker privileged mode | High | ⚠️ Needs review | `docker-compose.yml:11` |
| Docker socket mounting | Medium | ⚠️ Document risks | `docker-compose.yml:28` |
| Default DB password | Low | ⚠️ Improve docs | `docker-compose.yml:35` |
| Secure cookies default off | Low | ✅ Documented | `backend/src/server/config.rs:101` |
| Strong password validation | N/A | ✅ Implemented | `backend/src/server/auth/impl/api.rs` |
| SQL injection prevention | N/A | ✅ Implemented | `backend/src/server/shared/storage/` |
| Session security | N/A | ✅ Implemented | `backend/src/server/shared/storage/factory.rs` |
| No backdoors detected | N/A | ✅ Verified | All files |

---

## 🎯 Priority Recommendations

### Immediate (High Priority):
1. **Fix CORS configuration** in production mode to be more restrictive
2. **Evaluate Docker privileged mode** - migrate to specific capabilities if possible
3. **Document security implications** of privileged daemon and Docker socket access

### Short Term (Medium Priority):
4. **Add security warning banner** to deployment documentation
5. **Implement security headers** (CSP, X-Frame-Options, etc.)
6. **Add rate limiting** to API endpoints (beyond just login)

### Long Term (Low Priority):
7. **Consider security audit** by third-party firm before major release
8. **Implement security logging** for audit trail
9. **Add intrusion detection** capabilities

---

## 🏁 Conclusion

NetVisor demonstrates strong security fundamentals with no backdoors detected. The main concerns relate to deployment configuration choices (privileged Docker mode, permissive CORS) rather than code-level vulnerabilities.

**Recommendation:** Address the CORS configuration and improve security documentation around Docker deployment before production release.

**Analyst Notes:**
- Code quality is high with good use of modern security practices
- Authentication and authorization are well-implemented
- SQL injection and XSS protections are properly applied
- The privilege requirements (Docker socket, network scanning) are inherent to the application's purpose but should be clearly documented

---

**Report Generated By:** Claude Code Security Analysis
**Methodology:** Static code analysis, configuration review, pattern matching
**Scope:** Complete codebase analysis including backend, frontend, and configuration files
