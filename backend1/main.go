package main

import (
	"context"
	"github.com/gin-gonic/gin"
	"github.com/peterhellberg/swapi"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"log"
	"swapp-backend/api"
	"swapp-backend/utils"
)

func main() {
	var err error

	// Connect to MongoDB
	utils.Mongo, err = mongo.Connect(context.TODO(), options.Client().ApplyURI(utils.GetEnv("MONGO_URI", "mongodb://localhost:27017")))
	if err != nil {
		log.Fatal(err)
		return
	}
	err = utils.Mongo.Ping(context.TODO(), nil)
	if err != nil {
		log.Fatal(err)
		return
	}
	utils.DB = utils.Mongo.Database(utils.GetEnv("MONGO_DB", "starwars"))

	// Create StarWars API Client
	utils.SWApi = swapi.NewClient()

	// Create router
	r := gin.Default()

	// Define API Methods
	r.GET("/api/update", api.Update)
	r.GET("/api/report", api.Report)
	r.GET("/api/persons", api.Persons)
	r.GET("/api/starships", api.Starships)
	r.GET("/health", api.Health)

	// Listen
	r.Run(utils.GetEnv("LISTEN_ADDRESS", ":8000"))
}
