FROM alpine:3.11.6 AS build
WORKDIR /app
RUN apk add --no-cache go
COPY . .
RUN go build -o app swapp-backend

FROM alpine:3.11.6
WORKDIR /app
COPY --from=build /app/app /app/app
CMD ["/app/app"]
