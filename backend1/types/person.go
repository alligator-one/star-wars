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

type Person struct {
	Name      string       `json:"name"`
	Gender    string       `json:"gender"`
	Homeworld swapi.Planet `json:"homeworld"`
	Starships []Starship   `json:"starships,omitempty"`
}

var personsMutex sync.Mutex

func UpdatePersons() {
	// Prevent race condition
	personsMutex.Lock()
	defer personsMutex.Unlock()

	// Delete old data
	_, err := utils.DB.Collection("persons").DeleteMany(context.TODO(), bson.D{{}})
	if err != nil {
		log.Println(err)
		return
	}

	// Update persons
	var people struct {
		Count    int            `json:"count"`
		Next     *string        `json:"next"`
		Previous *string        `json:"previous"`
		Results  []swapi.Person `json:"results"`
	}
	first := "https://swapi.dev/api/people/"
	people.Next = &first
	for people.Next != nil { // Get all persons
		response, err := http.Get(*people.Next)
		if err != nil {
			log.Println(err)
			return
		}

		err = json.NewDecoder(response.Body).Decode(&people)
		if err != nil {
			log.Println(err)
			return
		}

		for _, result := range people.Results { // Insert data to DB
			var person Person

			person.Homeworld, err = utils.SWApi.Planet(utils.GetID(result.Homeworld))
			if err != nil {
				log.Println(err)
				return
			}

			person.Name = result.Name
			person.Gender = result.Gender

			starships := make([]Starship, 0)
			for _, url := range result.StarshipURLs {
				var starship Starship
				starshipResult, err := utils.SWApi.Starship(utils.GetID(url))
				if err != nil {
					log.Println(err)
					return
				}

				starship.Name = starshipResult.Name
				starship.Model = starshipResult.Model
				starship.Manufacturer = starshipResult.Manufacturer
				starship.CostInCredits = starshipResult.CostInCredits
				starship.Length = starshipResult.Length
				starship.Crew, err = strconv.Atoi(starshipResult.Crew)
				if err != nil {
					starship.Crew = -1
				}
				starship.Cargo, err = strconv.Atoi(starshipResult.CargoCapacity)
				if err != nil {
					starship.Cargo = -1
				}
				starship.StarshipClass = starshipResult.StarshipClass

				starships = append(starships, starship)
			}

			person.Starships = starships

			_, err = utils.DB.Collection("persons").InsertOne(context.TODO(), person)
			if err != nil {
				log.Println(err)
				return
			}
		}
	}
}
