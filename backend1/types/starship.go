package types

import (
	"context"
	"encoding/json"
	"github.com/peterhellberg/swapi"
	"go.mongodb.org/mongo-driver/bson"
	"log"
	"net/http"
	"strconv"
	"swapp-backend/utils"
	"sync"
)

type Starship struct {
	Name          string   `json:"name"`
	Model         string   `json:"model"`
	Manufacturer  string   `json:"manufacturer"`
	CostInCredits string   `json:"cost_in_credits"`
	Length        string   `json:"length"`
	Crew          int      `json:"crew"`
	Cargo         int      `json:"cargo"`
	StarshipClass string   `json:"starship_class"`
	Pilots        []Person `json:"pilots,omitempty"`
}

var starshipsMutex sync.Mutex

func UpdateStarships() {
	// Prevent race condition
	starshipsMutex.Lock()
	defer starshipsMutex.Unlock()

	// Delete old data
	_, err := utils.DB.Collection("starships").DeleteMany(context.TODO(), bson.D{{}})
	if err != nil {
		return
	}

	// Update starships
	var starships struct {
		Count    int              `json:"count"`
		Next     *string          `json:"next"`
		Previous *string          `json:"previous"`
		Results  []swapi.Starship `json:"results"`
	}
	first := "https://swapi.dev/api/starships/"
	starships.Next = &first
	for starships.Next != nil { // Get all starships
		response, err := http.Get(*starships.Next)
		if err != nil {
			return
		}

		_ = json.NewDecoder(response.Body).Decode(&starships)

		var starship Starship
		for _, result := range starships.Results { // Insert data to DB
			starship.Name = result.Name
			starship.Model = result.Model
			starship.Manufacturer = result.Manufacturer
			starship.CostInCredits = result.CostInCredits
			starship.Length = result.Length
			starship.Crew, err = strconv.Atoi(result.Crew)
			if err != nil {
				starship.Crew = -1
			}
			starship.Cargo, err = strconv.Atoi(result.CargoCapacity)
			if err != nil {
				starship.Cargo = -1
			}
			starship.StarshipClass = result.StarshipClass

			persons := make([]Person, 0)
			for _, personURL := range result.PilotURLs {
				var person Person

				personResult, err := utils.SWApi.Person(utils.GetID(personURL))
				if err != nil {
					return
				}

				person.Name = personResult.Name
				person.Gender = personResult.Gender
				person.Homeworld, err = utils.SWApi.Planet(utils.GetID(personResult.Homeworld))
				if err != nil {
					log.Println(err)
					return
				}

				persons = append(persons, person)
			}

			starship.Pilots = persons

			_, err = utils.DB.Collection("starships").InsertOne(context.TODO(), starship)
			if err != nil {
				log.Println(err)
				return
			}
		}
	}
}
