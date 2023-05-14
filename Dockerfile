FROM golang:alpine as builder

WORKDIR /app

COPY gin.go .

RUN go mod init web

RUN go get -u github.com/gin-gonic/gin

RUN go build -o ./web .

FROM alpine:latest

WORKDIR /root/

COPY --from=builder /app/web .

EXPOSE 8080

CMD ["./web"]