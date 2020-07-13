package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/models"
	"bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/utils"
)

var bootedHosts []models.Machine

// AddBootedHostHandler adds a host to the slice of booted hosts
func AddBootedHostHandler(w http.ResponseWriter, r *http.Request) {
	// swagger:operation POST /v1/inventory Inventory Inventory
	//
	// Add a booted host to host inventory
	// ---
	// consumes:
	// - application/json
	// produces:
	// - text/plain
	// parameters:
	// - name: payload
	//   in: body
	//   description: Booted machine. Should include a MAC address and architecture
	//   required: true
	//   schema:
	//     "$ref": "#/definitions/Machine"
	// responses:
	//   '200':
	//     description: Machine added successfully
	//     type: string
	machine := &models.Machine{}
	err := json.NewDecoder(r.Body).Decode(&machine)
	machine.Date = time.Now().Format(time.RFC3339)
	if !(utils.ValidateJSON(err, w)) {
		return
	}

	bootedHosts = append(bootedHosts, *machine)
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "Added machine to booted hosts inventory: %s\n", machine.Type)
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
	res := struct {
		Count int
		Hosts []models.Machine
	}{
		Count: len(bootedHosts),
		Hosts: bootedHosts,
	}
	hosts, _ := json.MarshalIndent(res, "", "  ")
	fmt.Fprintf(w, "%s", hosts)
}
