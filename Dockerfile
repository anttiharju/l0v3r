FROM golang:1.24.3-alpine3.21 AS builder

WORKDIR /build

COPY . .

RUN CGO_ENABLED=0 go build -ldflags "-s -w -buildid=" -trimpath -o l0v

FROM haproxy:3.2.0-alpine3.21

WORKDIR /app

COPY --from=builder /build/l0v /app/l0v

ENV PATH="/app:${PATH}"

# Default entrypoint is still the HAProxy default
# This allows you to run the container normally with HAProxy while still being able to exec in
