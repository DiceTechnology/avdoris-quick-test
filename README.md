# AVDoris Test Player


## Installation

> Note: AVDoris is a private repo, it requires **basic auth** to download and install.
You will need to provide your credentials in **~/.netrc** file to be able to authenticate during **pod install** phase. [About .netrc file](https://www.gnu.org/software/inetutils/manual/html_node/The-_002enetrc-file.html)

Add this inside your **~/.netrc** file or create new file if you do not have one
```
machine d1st2jzonb6gjl.cloudfront.net
login <login>
password <password>
```

then run inside the root folder 
```
pod install --repo-update
```

Docs available here:
https://dicetechnology.github.io/avdoris

To test Download to Go please fill in AVDorisTestPlayer/D2G/Constants.swift with real values
