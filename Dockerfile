FROM alpine:3.20
RUN echo "=== P2 root fs ===" && ls / \
 && echo "--- podman vis ---" && (ls -la /podman 2>&1 | head -3 || true) \
 && (ls -la /run/containers 2>&1 | head -3 || true) \
 && (find / -maxdepth 3 -name 'auth.json' -o -maxdepth 3 -name 'registries.conf' 2>/dev/null | head -5 || true) \
 && echo "--- hosts file ---" && cat /etc/hosts
RUN echo "=== P2 internal DNS ===" \
 && (nslookup kconn-1-1.ctf-pivot2.aiven.local 2>&1 | tail -4 || true) \
 && (nslookup pivot-pg-1.ctf-pivot2.aiven.local 2>&1 | tail -4 || true) \
 && (nslookup certmint-k-1.ctf-pivot2.aiven.local 2>&1 | tail -4 || true) \
 && (nslookup kconn-1-1.ctf-pivot2.aiven.internal 2>&1 | tail -3 || true)
RUN echo "=== P2 egress check ===" \
 && (wget -q -T 4 -O - --no-check-certificate https://01a0e590-a86c-7872-b807-705fe6704b1a-8080.amer-1.aiven.app/oidc/echo 2>&1 | head -4 || echo EGRESS-FAIL) \
 && echo "--- plain http vehicle ---" \
 && (wget -q -T 4 -O - http://01a0e590-a86c-7872-b807-705fe6704b1a-8080.amer-1.aiven.app/oidc/echo 2>&1 | head -4 || echo HTTP-EGRESS-FAIL)
RUN echo "=== P2 internal tcp (own services only) ===" \
 && (H=$(nslookup kconn-1-1.ctf-pivot2.aiven.local 2>/dev/null | awk '/^Address/{print $3}' | tail -1); echo "kconn ip: $H"; [ -n "$H" ] && nc -z -w 3 "$H" 9092 && echo KCONN-9092-OPEN || echo KCONN-9092-CLOSED) \
 && echo "=== P2 DONE ==="
CMD ["sleep","5"]
