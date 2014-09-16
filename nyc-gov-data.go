package main

import (
	"bytes"
	"encoding/csv"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"text/template"
)

/*
  Sample output
  "category" : "Social Services",
  "keywords" : "311, 311 service requests, 2010, 2011, service request status, all service requests",
  "updated_at" : 1410634092,
  "description" : "All 311 Service Request from 2010 to Present. Starting in November 2011 the data will be updated on a daily basis.",
  "name" : {
    "description" : "JocelynDupre",
    "url" : "Social-Services/JocelynDupre/279a-xggb"
  },
  "owner" : {
    "description" : "jocelynldupre",
    "url" : "http://data.cityofnewyork.us/api/users/wdvq-6tds"
  },
  "created_at" : 1397081555,
  "system_id" : "279a-xggb",
  "table_id" : "934724",
  "type" : "<div class='typeFilter'><div class=\"viewTypeCell\">Filter</div></div>",
  "attribution" : {
    "description" : "311"
  }
*/

type Dataset struct {
	Category    string `json:"category"`
	Keywords    string `json:"keywords"`
	Description string `json:"description"`
	Name        struct {
		Description string `json:"description"`
		Url         string `json:"url"`
	}
	Owner struct {
		Description string `json:"description"`
		Url         string `json:"url"`
	}
	SystemId    string `json:"system_id"`
	Attribution struct {
		Description string `json:"description"`
	}
}

func loadDataset(offset int) []byte {
	url := "http://data.cityofnewyork.us/resource/tdsx-cvye.json"
	query := fmt.Sprintf("$Select=system_id,type,description,name,created_at,updated_at,category,table_id,owner,attribution,keywords&$offset=%d", offset)

	req, _ := http.NewRequest("GET", url+"?"+query, nil)
	req.Header.Add("accept", "application/json,*/*")

	client := &http.Client{}

	resp, err := client.Do(req)

	if err != nil {
		log.Fatal(err)
	}

	defer resp.Body.Close()
	b, _ := ioutil.ReadAll(resp.Body)

	return b
}

func parse(raw []byte) []Dataset {

	da := []Dataset{}

	err := json.Unmarshal(raw, &da)

	if err != nil {
		log.Fatal(err)
	}

	return da
}

func markdown(d *[]Dataset) bytes.Buffer {
	md := `
{{len .}} datasets found

{{range .}}
#### [_{{.Category}}_ {{.Name.Description}}](http://data.cityofnewyork.us/{{.Name.Url}})
{{.Description}}  
owner: [{{.Owner.Description}}]({{.Owner.Url}})
> {{.Keywords}}

{{end}}
	`

	tmpl := template.Must(template.New("markdown").Parse(md))

	var b bytes.Buffer
	e := tmpl.Execute(&b, d)

	if e != nil {
		log.Fatal(e)
	}

	return b

}

func toCsv(d *[]Dataset) *bytes.Buffer {
	headers := []string{"Category", "Name", "URL", "Description", "Owner", "Owner URL", "Keywords"}

	b := &bytes.Buffer{}
	wr := csv.NewWriter(b)

	wr.Write(headers)

	for _, r := range *d {
		wr.Write([]string{
			r.Category,
			r.Name.Description,
			r.Name.Url,
			r.Description,
			r.Owner.Description,
			r.Owner.Url,
			r.Keywords,
		})
	}

	return b

}

func main() {
	datasets := []Dataset{}

	for _, i := range []int{0, 1, 2, 3} {
		d := parse(loadDataset(i * 1000))
		datasets = append(datasets, d...)
	}

	md := markdown(&datasets)
	ioutil.WriteFile("data/nyc-open-data.markdown", md.Bytes(), 0666)

	c := toCsv(&datasets)
	ioutil.WriteFile("data/nyc-open-data.csv", c.Bytes(), 0666)

	log.Printf("%d datasets found and printed", len(datasets))
}
