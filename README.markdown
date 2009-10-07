# NYC GOV Data #

See [Big Apps](http://www.nycbigapps.com/) and [NYC Data](http://nyc.gov/data)

After trying to explore the various datasets online I wanted to just have one list of all datasets.

This is a Rhino based javascript which will parse the available datasets and dump them to a text file and a json file.  See /data for these files.

Those maybe of interest to you.

## Usage ##

Probably the easiest thing is to just vist <http://github.com/jweir/nyc-gov-data/blob/master/data/nyc_data_sets.markdown> and view the datasets.

To run locally have [Rhino](http://www.mozilla.org/rhino/) installed. _I think that recent versions of Java hava Rhino by default._

  `java org.mozilla.javascript.tools.shell.Main -f parse_data.js`

## Legal ##

From [http://nyc.gov/html/datamine/html/terms/terms.shtml](http://nyc.gov/html/datamine/html/terms/terms.shtml)

> The City of New York can not vouch for the accuracy or completeness of data provided by this web site or application or for the usefulness or integrity of the web site or application.  This site provides applications using data that has been modified for use from its original source, NYC.gov, the official web site of the City of New York.