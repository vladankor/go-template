FROM golang:alpine AS builder

WORKDIR /app

# Копируем и скачиваем необходимые модули
COPY go.mod  go.sum ./
RUN go mod download

COPY . .

# Устанавливаем библиотеку для генерации swagger
RUN go install github.com/swaggo/swag/cmd/swag
# Запускаем генерацию api документации
RUN swag init -g main.go --output docs 

# Билдим проект
RUN go build cmd/app/main.go

FROM golang:alpine

WORKDIR /app

# Копируем необходимые файлы из билда 
COPY --from=builder /app/main .
COPY --from=builder /app/docs ./docs
# COPY --from=builder /app/config ./config

EXPOSE 8080

CMD ["/app/main"]
