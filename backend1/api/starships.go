package api

import (
	"context"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo/options"
	"log"
	"net/http"
	"strconv"
	"swapp-backend/types"
	"swapp-backend/utils"
)

func Starships(c *gin.Context) {
	// Get count of results
	count, err := strconv.Atoi(c.Query("count"))
	if count <= 0 || err != nil {
		count = 10
	}

	// Find starship
	persons, err := utils.DB.Collection("starships").Find(context.TODO(), bson.D{}, options.Find().SetLimit(int64(count)))
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, map[string]interface{}{"error": err, "result": nil})
		return
	}

	result := make([]types.Starship, 0)
	for persons.Next(context.TODO()) { // Decode results
		var starship types.Starship
		err = persons.Decode(&starship)
		if err != nil {
			log.Println(err)
			c.JSON(http.StatusInternalServerError, map[string]interface{}{"error": err, "result": nil})
			return
		}
		result = append(result, starship) // Append to results array
	}

	c.JSON(http.StatusOK, map[string]interface{}{"error": nil, "result": result})
}
