package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/sgryczan/titania/api/models"
	"github.com/sgryczan/titania/api/utils"
)

// ListHandler lists all hosts in the inventory
func ListHandler(w http.ResponseWriter, r *http.Request) {
	// swagger:operation GET /hosts BootConfig Item
	//
	// Lists all hosts in the inventory
	// ---
	// consumes:
	// - text/plain
	// produces:
	// - application/json
	//
	// responses:
	//   '200':
	//     description: Success
	//     type: string
	inv := models.Inventory{}

	hosts, err := utils.ListHostFiles()
	if err != nil {
		log.Print(err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	inv.Count = len(hosts)
	inv.Hosts = hosts

	res, err := json.MarshalIndent(inv, "", "  ")

	if err != nil {
		log.Print(err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "%s", res)
}

// ListBootedHostsHandler lists the inventory of booted hosts
func ListBootedHostsHandler(w http.ResponseWriter, r *http.Request) {
	// swagger:operation GET /v1/inventory Inventory Inventory
	//
	// Lists booted host inventory
	// ---
	// consumes:
	// - application/json
	// produces:
	// - application/json
	// responses:
	//   '200':
	//     description: Machine added successfully
	//     type: string
	w.WriteHeader(http.StatusOK)
	res, err := utils.ListInventoryFiles()
	if err != nil {
		log.Print(err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}
	hosts, _ := json.MarshalIndent(res, "", "  ")
	fmt.Fprintf(w, "%s", hosts)
}
