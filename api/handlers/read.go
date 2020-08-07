package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"path/filepath"
	"strconv"

	"github.com/sgryczan/titania/api/utils"
)

// ReadHandler handles host additions
func ReadHandler(w http.ResponseWriter, r *http.Request) {
	// swagger:operation GET /host/{mac} BootConfig read
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
	// responses:
	//   '200':
	//     description: MAC details retrieved successfully
	//     type: string
	// responses:
	//   '400':
	//     description: MAC configuration not found
	//     type: string

	mac := filepath.Base(r.URL.Path)
	fmt.Printf("GET /host/%s\n", mac)

	host, err := utils.ReadHostFromFile(mac)
	if err != nil {
		log.Print(err.Error())
		w.WriteHeader(http.StatusNotFound)
		fmt.Fprintf(w, "config for mac %s not found", mac)
		return
	}

	res, err := json.MarshalIndent(host.Config, "", "  ")

	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "%s", res)
	log.Print(fmt.Sprintf("retrieved config for host: %v\n", mac))

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
	//   description: Return events for this MAC.
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
