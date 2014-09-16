# NYC GOV Data #

See [Big Apps](http://www.nycbigapps.com/) and [NYC Data](http://nyc.gov/data)

Many years ago I was trying to get a handle on the data sets that NYC had available.  But the list was paginiated and hard to view.

So I wrote this to download all the available datasets.  The original version used the old javascript engine, Rhino, and was written in javascript.

After noticing people are still using this, I rewrote it.

## Usage ##

The easiest thing is to just download the 
[csv](http://github.com/jweir/nyc-gov-data/blob/master/data/nyc-open-data.csv) version of the dataset.

_The new dataset is too large to view on Github._


There is an archive of the old data sets [here](http://github.com/jweir/nyc-gov-data/blob/master/data/nyc-open-data-archive.markdown).

PS: There are close to 4000 datasets now.


To run locally you will need [Go](http://www.golang.org) installed.

    git clone https://github.com/jweir/nyc-gov-data.git
    cd nyc-gov-data
    go run nyc-gov-data.go

## Legal ##

You might want to review the Terms of Use at [http://www1.nyc.gov/home/terms-of-use.page](http://www1.nyc.gov/home/terms-of-use.page) before diving in.
