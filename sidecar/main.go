// A simple API for PixieCore
//
// An API Definition to manage pixiecore hosts
//
//	   Schemes: http, https
//     BasePath: /
//     Version: 0.0.1
//     Contact: Team Tengu<ng-sf-sre-teamn@netapp.com> https://bitbucket.ngage.netapp.com/projects/HCIT/repos/pixiecore-dynamic-rom/browse/api
// swagger:meta
package main

import (
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"
	"github.com/sgryczan/titania/api/handlers"
)

var hostsDir string
var listenPort string

func main() {
	version := handlers.Version
	if os.Getenv("PORT") == "" {
		listenPort = "8080"
	}
	if os.Getenv("HOSTS_DIR") == "" {
		hostsDir = "/hosts"
	}

	rand.Seed(time.Now().UnixNano())

	r := mux.NewRouter()
	//r.UseEncodedPath()
	//r.SkipClean(true)
	fmt.Println("Started api v" + version)

	r.HandleFunc("/", handlers.HomeHandler)
	r.HandleFunc("/about", handlers.AboutHandler)
	r.HandleFunc("/v1/boot/{mac}", handlers.BootHandler).Methods("GET")
	r.HandleFunc("/host/{mac}", handlers.ReadHandler).Methods("GET")
	r.HandleFunc("/host/{mac}", handlers.AddHandler).Methods("POST")
	r.HandleFunc("/host/{mac}", handlers.DeleteHandler).Methods("DELETE")
	r.HandleFunc("/hosts", handlers.ListHandler).Methods("GET")
	r.HandleFunc("/v1/inventory", handlers.AddBootedHostHandler).Methods("POST")
	r.HandleFunc("/v1/inventory", handlers.ListBootedHostsHandler).Methods("GET")

	sh := http.StripPrefix("/api",
		http.FileServer(http.Dir("./swaggerui/")))
	r.PathPrefix("/api/").Handler(sh)

	srv := &http.Server{
		Handler:      r,
		Addr:         ":8080",
		WriteTimeout: 10 * time.Second,
		ReadTimeout:  10 * time.Second,
	}

	log.Fatal(srv.ListenAndServe())
}
