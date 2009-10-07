/*
  Javascript (using Narwhal + Rhino) for parsing the list of NYC.gov datasets.
  make sure that Narwhal js is in your path
  http://narwhaljs.org/quick-start.html
*/

load("lib/json2.js");
importPackage(java.io);

(function(){
  // 10 fields
  // via http://www.nyc.gov/html/datamine/html/data/../../includes/scripts/nav_nodes.js
  var dataSetIndex = [
    "category",
    "dataSets",
    "description",
    "agency",
    "url",
    "fileName",
    "fileType",
    "dateInfo",
    "keywords",
    "related"];

  function get(name){
    return readUrl("http://www.nyc.gov/html/datamine/includes/scripts/"+name+".js");
  }

  function parse(source){
    eval(source);
    for (var i=0; i < datasets.length; i++) {
      map(datasets[i])
    };
  }

  function map(array){
    var category = array[0],
        dataset = {};

    // Start at 1, skip category
    for (var i=1; i < dataSetIndex.length; i++) {
      dataset[dataSetIndex[i]] = array[i];
    };

    datasets[category] = datasets[category] || [];
    datasets[category].push(dataset)
  }

  var datasets = {};

  parse(get("raw"));
  parse(get("geo"));

  this.datasets = datasets;

})();

(function(){
  var out = "";

  function sorted_categories(){
    var categories = [];
    for(var category in datasets){
      categories.push(category);
    }
    return (categories.sort());
  }

  var categories = sorted_categories();

  function fields(set, additionalFields){
    for (var i=0; i < additionalFields.length; i++) {
      out += "   "+set[additionalFields[i]]+"\n";//["  ", set[additionalFields[i]]].join("\n");
    };
    if(additionalFields.length > 0){
      out += "\n";
    }
  }

  //////////////////////////////////////////////////////////////////////////////
  function markdown(){
    var sets, out = "";

    for (var x=0; x < categories.length; x++) {
      var category = categories[x];
      out += "# "+category+" #\n";
      sets = datasets[category];

      for (var i=0; i < sets.length; i++) {
        var set = sets[i];
        out += "* ## ["+set.dataSets+"]("+set.url+") ##\n";
        out += "  "+set.description+"\n";
        out += "  _format:"+set.fileType+"  updated:"+set.dateInfo+"_\n";
        out += "\n"
      };
      out += "\n"
    }
    return out;
  }

  //Converts the dataset into a string
  //call with an array of additional fields to include that data
  function text(additionalFields){
   var sets, out = "";

    for (var x=0; x < categories.length; x++) {
      var category = categories[x]

      out += category+"\n";
      sets = datasets[category];

      for (var i=0; i < sets.length; i++) {
        var set = sets[i];
        out += [" ", set.dataSets, " (", set.fileType,")", "\n"].join("");
        fields(sets[i], additionalFields);
      };
      out += "\n"
    }

    return out;
  }

  function json(){
    return JSON.stringify(datasets, null, "\t");
  }

  // Saves the text to file
  function save(format, fileName, additionalFields){
    additionalFields = additionalFields || [];

    var file = new java.io.FileWriter(fileName);
    try
    {
      file.write(this[format](additionalFields));
    }
    finally
    {
      file.close();
    }
  }

  this.json = json;
  this.text = text;
  this.markdown = markdown;
  this.save = save;
})();

save("text","data/nyc_data_sets.txt", ["url"]);
save("json","data/nyc_data_sets.json");
save("markdown","data/nyc_data_sets.markdown");
