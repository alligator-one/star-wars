package api

import (
	"context"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo/options"
	"log"
	"net/http"
	"sort"
	"strconv"
	"swapp-backend/types"
	"swapp-backend/utils"
)

func Report(c *gin.Context) {
	// Get count of results
	count, err := strconv.Atoi(c.Query("count"))
	if count <= 0 || err != nil {
		count = 10
	}

	// Find persons and sort by starships.cargo
	persons, err := utils.DB.Collection("persons").Find(context.TODO(), bson.D{}, options.Find()) // .SetSort(bson.D{{"starships.cargo", -1}}).SetLimit(int64(count))
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, map[string]interface{}{"error": err, "result": nil})
		return
	}

	result := make([]types.Person, 0)
	for persons.Next(context.TODO()) { // Decode results
		var person types.Person
		err = persons.Decode(&person)
		if err != nil {
			log.Println(err)
			c.JSON(http.StatusInternalServerError, map[string]interface{}{"error": err, "result": nil})
			return
		}
		result = append(result, person) // Append to results array
	}

	sort.Slice(result, func(i, j int) bool {
		first := -1
		second := -1
		for _, ship := range result[i].Starships {
			if ship.Cargo > first {
				first = ship.Cargo
			}
		}
		for _, ship := range result[j].Starships {
			if ship.Cargo > second {
				second = ship.Cargo
			}
		}
		return first > second
	})

	c.JSON(http.StatusOK, map[string]interface{}{"error": nil, "result": result[:count]})
}
