package handlers

import (
	"fmt"
	"log"
	"net/http"
	"path/filepath"

	"bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/utils"
)

// DeleteHandler deletes host configs
func DeleteHandler(w http.ResponseWriter, r *http.Request) {
	// swagger:operation DELETE /host/{mac} BootConfig delete
	//
	// Remove a host from inventory
	// ---
	// consumes:
	// - text/plain
	// produces:
	// - text/plain
	// parameters:
	// - name: mac
	//   in: path
	//   description: MAC of host config to be deleted.
	//   required: true
	//   type: string
	// responses:
	//   '200':
	//     description: Host removed successfully
	//     type: string

	mac := filepath.Base(r.URL.Path)
	err := utils.DeleteHostFile(mac)
	if err != nil {
		log.Print(err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
	}
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "Deleted host: %v\n", mac)
	log.Print(fmt.Sprintf("deleted host: %v\n", mac))

}
