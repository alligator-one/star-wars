package utils

import (
	"github.com/peterhellberg/swapi"
	"go.mongodb.org/mongo-driver/mongo"
	"os"
	"regexp"
	"strconv"
)

var Mongo *mongo.Client
var DB *mongo.Database
var SWApi *swapi.Client

func GetEnv(key, fallback string) string { // Get environment variable or default value
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

func GetID(url string) int { // Get ID from API URL
	id, err := strconv.Atoi(regexp.MustCompile("/(\\d+)/").FindStringSubmatch(url)[1])
	if err != nil {
		return -1
	}
	return id
}
