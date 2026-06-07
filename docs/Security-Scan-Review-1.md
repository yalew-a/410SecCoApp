# Security Scan #1

- Found 11 issues, 7 with medium severity, 4 with high severity.

## Notes:
- To fix a majority of the issues, the solution is to upgrade the current versions to a patched version. For example, the version of urllib3 package causes a majority of the issues, overall upgrading its version to 2.7.0 or higher is ideal. Along with, 'requests'- to 2.33.0 or higher. Regardless, each section of the specific issue will state what version the package should be upgraded to.

# High Severity:

## #1: Improper Handling of Highly Compressed Data (Data Amplification)
- Issue:
- The urllib3 library is susceptible to a resource exhaustion flaw (specifically, Data Amplification) within its Streaming API components. This issue stems from the way the ContentDecoder class processes highly compressed incoming data. If an attacker delivers a payload specifically engineered with a large compression ratio (often referred to as a "zip bomb"), the library can be forced to allocate a disproportionate amount of system memory or CPU to decompress a single data chunk.

- Additional Notes:
- This unexpected resource spike can be triggered when consuming streaming data using any of the following methods:

- stream()
- read(amt=256)
- read1(amt=256)
- read_chunked(amt=256)
- readinto(b)

- How to fix: Upgrading the current version of 'urllib3' to 2.6.0 or higher.


## #2:  Allocation of Resources Without Limits or Throttling
- Issue:
- This package is susceptible to an uncontrolled resource allocation flaw when decompressing incoming server response data. An attacker can exploit this by returning a response that uses huge amount of layered, chained compression algorithms. Attempting to unpack these complex layers forces the application to consume large amounts of CPU and memory, potentially leading to a system crash or Denial of Service (DoS).

- Additional Notes:
- Aside from upgrading the current version, to protect the application from this exploit, you can disable automatic content preloading and vetting the response metadata before processing the payload.
- Specifically- Set preload_content=False on the request.
- Check the resp.headers["content-encoding"] header to ensure the number of applied compression layers is strictly limited to a safe quantity before reading the data stream.

- How to fix: Upgrading current version of 'urllib3' to 2.6.0 or higher.


## #3: Improper Handling of Highly Compressed Data (Data Amplification)
- Issue:
- This package is susceptible to a Data Amplification (resource exhaustion) vulnerability within its streaming API when handling HTTP redirects. If an application follows a redirect to a malicious destination, an attacker can return a highly compressed payload specifically engineered to expand exponentially upon arrival. Because the library attempts to decompress this large amount of data before applying any standard read limits, it can completely exhaust the host system's CPU and memory.

- Additional Notes:
- But, the exploit is only viable if your application streams content from unverified or untrusted external sources while allowing automatic HTTP redirects.

- How to fix: Upgrading current version of 'urllib3' to 2.6.3 or higher.
- Or additionally, disabling automatic redirect following when querying untrusted endpoints. To do this, explicitly set the redirect=False parameter on those specific requests.


## #4: Insertion of Sensitive Information Into Sent Data
- Issue:
- The vulnerability of data exposure in this package is when low-level connection pooling is used incorrectly. Specifically, calling ProxyManager.connection_from_url() with assert_same_host=False via urlopen() fails to trigger standard header scrubbing during cross-origin redirects. An attacker can exploit this to intercept sensitive headers like Authorization, Cookie, and Proxy-Authorization.

- Additional Notes:
- only affects direct usage of these low-level connection methods. Applications are safe if they exclusively use standard high-level APIs, such as:

- urllib3.request()
- PoolManager.request()
- ProxyManager.request()

- How to fix: Upgrading the current version of 'urllib3' to 2.7.0 or higher.



# Medium Severity:

## #1: Insertion of Sensitive Information Into Sent Data
- Issue:
- Due to a flaw in how this package parses URLs, sensitive user data can be exposed. Specifically, an attacker can design a deceptive URL that misleads the library into transmitting a user's .netrc login credentials to an external, attacker-controlled server.

- Additional notes: This attack only succeeds if the victim's .netrc file holds active credentials for the specific domain the attacker targets in the URL structure (e.g., leveraging example.com within [http://example.com:@evil.com/](http://example.com:@evil.com/)).


- How to fix: Upgrading the 'requests' version to 2.32.4, or higher.


## #2: Insecure Temporary File
- Issue:
- With versions of this package, it involes insecure temporary file handling within the extract_zipped_paths function. If an attacker creates a malicious file in the system's temporary folder before the extraction process happens, they can overwrite or replace files without authorization.

- Additional Notes: This issue only impacts applications that explicitly invoke the extract_zipped_paths() function directly.

- How to fix: Upgrading 'requests' version to 2.33.0 or higher.


## #3: Information Exposure
- Issue:
- Certain versions of this package are susceptible to data exposure because they mistakenly forward Proxy-Authorization headers to the final destination server during specific HTTP redirects. This leak occurs due to how the rebuild_proxies function handles and re-attaches credentials when a request is rerouted.

- Additional Notes:
- This flaw specifically affects proxied requests where the credentials are embedded directly within the URL (e.g., https://username:password@proxy:8080), and it only triggers when the final destination is an HTTPS origin:

- HTTP → HTTPS: Leaks credentials
- HTTPS → HTTPS: Leaks credentials
- Any destination ending in HTTP: Safe (No leak)

- How to fix: Upgrading 'requests' version to 2.31.0 or higher.


## #4: Always-Incorrect Control Flow Implementation
- Issue:
- Specific versions of this package have logic flaw in how request control flow is managed within a Session object. If the very first request in a session is made with certificate validation turned off (verify=False), the session locks into that insecure state. Consequently, all subsequent requests within that session will skip certificate verification, even if you explicitly try to turn it back on later.

- Additional Notes:
- If you're not able to upgrade immediately, you can avoid this issue by using these temporary solutions:
- Do not set verify=False on the initial request to a host when utilizing a Session.
- If you must use verify=False, call Session.close() immediately afterward to clear out the cached, unverified connection before making new requests.

- How to fix it: Upgrading 'requests' to 2.32.2 version or higher.

## 5: Regular Expression Denial of Service (ReDoS)
- Issue:
- This package version is susceptible to a Regular Expression Denial of Service (ReDoS) flaw within its idna.encode() function. The issue occurs because unusually large, specialized domain name inputs can trigger an inefficient validation routine in the valid_contexto() function before any length checks take place. Processing these oversized inputs can stall the application, causing it to hang or crash.

- Additional notes:
- If you cannot upgrade immediately, you can completely block this attack by implementing a strict input validation rule in your application code: ensure no domain name string exceeding the standard limit of 253 characters is passed to the encoding function.

- How to fix: Upgrading 'idna' to 3.15 version or higher.


## #6: Resource Exhaustion
- Info:
- Certain versions of this package are susceptible to a Resource Exhaustion flaw within the idna.encode function. By passing highly specific, engineered arguments to this function, an attacker can force the system to consume excessive CPU or memory, potentially triggering a Denial of Service (DoS) that renders the application unresponsive.

- Additional Notes:
- This attack relies on sending an unusual and large amount of formatted inputs that wouldn't usually appear during standard system operations. However, if the parent application lacks up-front input validation and blindly passes raw user-supplied data directly to the library, it remains vulnerable to this exploit.

- How to fix: Upgrading current version of 'idna' to 3.7 or higher.


## #7: Open Redirect 
- Issue: 
- This package is vulnerable to an Open Redirect flaw because the retries parameter is completely disregarded during the initialization of the PoolManager. When an application assumes that redirects are disabled at the connection pool layer, the library may still automatically follow them anyway. An attacker can exploit this unexpected behavior to force the application to connect to unintended external resources or malicious endpoints.

- Additional Notes:
- Systems using requests or botocore are not impacted by this specific vulnerability, as those libraries handle connection pooling differently.

- How to fix: Upgrading current version of 'urllib3' to 2.5.0 or higher.