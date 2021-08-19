package api

import "github.com/gin-gonic/gin"

func Health(c *gin.Context) {
	c.JSON(200, map[string]interface{}{"error": nil})
}