# --- Build Stage ---
FROM golang:1.23-alpine AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Add git for fetching dependencies
RUN apk add --no-cache git build-base

# We want to populate the module cache based on the go.mod file.
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go app
# CGO_ENABLED=1 is required for go-sqlite3
# -o /app/apimain places the output binary in the /app directory
RUN CGO_ENABLED=1 GOOS=linux go build -o /app/apimain cmd/apimain.go


# --- Final Stage ---
FROM alpine:latest

# Set the Current Working Directory inside the container
WORKDIR /app

# Add tzdata for timezone support
RUN apk add --no-cache tzdata

# Copy the binary from the builder stage
COPY --from=builder /app/apimain .

# This container exposes port 21114 to the outside world
EXPOSE 21114

# Command to run the executable
CMD ["./apimain"]