package api

import (
	"github.com/gin-gonic/gin"
	"net/http"
	"swapp-backend/types"
)

func Update(c *gin.Context) {
	go types.UpdatePersons()
	go types.UpdateStarships()
	c.JSON(http.StatusOK, map[string]interface{}{})
}
