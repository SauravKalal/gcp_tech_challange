FROM golang:alpine AS builder

# Set necessary environmet variables needed for our image
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    ENVIRONMENT=dev

# Move to working directory /build
WORKDIR /build

# Copy the code into the container
COPY . .

# Build the application
RUN go build -o main .

# Move to /dist directory as the place for resulting binary folder
WORKDIR /dist

# Copy binary from build to main folder
RUN cp /build/main .

# Copy the configuration file
RUN cp /build/config.json .

# Copy project assets
RUN cp -r /build/assets/ .

RUN rm -r /build/

FROM alpine:latest

WORKDIR /dist

COPY --from=builder dist/main /dist/

COPY --from=builder dist/config.json /dist/

COPY --from=builder dist/assets /dist/assets

RUN addgroup -S tom && adduser -S tom -G tom

RUN chown -R tom:tom /dist

USER tom

ENV ENVIRONMENT=dev

# Export necessary port
EXPOSE $port_of_app

# Command to run when starting the container
CMD ["./main"]