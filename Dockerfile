# syntax=docker/dockerfile:1

FROM golang:1.22-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum* ./
RUN go mod download

# Копируем исходники и vendor'им зависимости
COPY *.go ./
RUN go mod vendor

# Собираем с использованием vendor
RUN CGO_ENABLED=0 GOOS=linux go build -mod=vendor -ldflags="-w -s" -o parcel-tracker .

FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

COPY --from=builder /app/parcel-tracker .

CMD ["./parcel-tracker"]