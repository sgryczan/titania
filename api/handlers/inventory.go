package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"path/filepath"
	"strconv"
	"time"

	"github.com/sgryczan/titania/api/models"
	"github.com/sgryczan/titania/api/utils"
)

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
	//     "$ref": "#/definitions/MachineEvent"
	// responses:
	//   '200':
	//     description: Machine added successfully
	//     type: string
	event := &models.MachineEvent{}
	err := json.NewDecoder(r.Body).Decode(&event)
	event.Date = time.Now().Format(time.RFC3339)
	if !(utils.ValidateJSON(err, w)) {
		return
	}

	//bootedHosts = append(bootedHosts, *machine)
	// Write host to file
	err = utils.UpdateBootedHostInventory(event)
	if err != nil {
		log.Print(err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "Added event type to booted hosts inventory: %s\n", event.Type)
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

// GetHostEventsHandler returns boot events for a given host
func GetHostEventsHandler(w http.ResponseWriter, r *http.Request) {
	// swagger:operation GET /v1/inventory/{mac} Inventory read
	//
	// Retrieves the boot details of a given host
	// ---
	// consumes:
	// - text/plain
	// produces:
	// - application/json
	// parameters:
	// - name: mac
	//   in: path
	//   description: MAC of host config to be returned.
	//   required: true
	//   type: string
	// - name: maxResults
	//   in: query
	//   description: Max number of events to be returned
	//   required: false
	//   type: int
	//   default: 1
	// responses:
	//   '200':
	//     description: MAC details retrieved successfully
	//     type: string
	// responses:
	//   '400':
	//     description: MAC configuration not found
	//     type: string

	q := r.FormValue("maxResults")
	results, _ := strconv.Atoi(q)
	if results == 0 {
		results = 1
	}

	mac := filepath.Base(r.URL.Path)
	fmt.Printf("GET /v1/inventory/%s\n", mac)

	hostInv, err := utils.ReadBootedHostsInventoryFromFile("inventory/" + mac)
	if err != nil {
		log.Print(err.Error())
		w.WriteHeader(http.StatusNotFound)
		fmt.Fprintf(w, "Boot events for mac %s not found", mac)
		return
	}

	events := hostInv.Events

	if len(hostInv.Events) >= results {
		events = hostInv.Events[len(hostInv.Events)-results:]
	}

	hostInv.Events = events
	res, _ := json.MarshalIndent(events, "", "  ")

	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "%s", res)
	log.Print(fmt.Sprintf("retrieved config for host: %v\n", mac))

}
