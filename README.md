# MB-scripts
various Musicbrainz stuff

overly simplistic ways to use:
$ wget -O - https://musicbrainz.org/ws/2/recording?work=36df44f5-7cad-37ee-9aae-89a5c58dfb07\&inc=artist-credits+event-rels+place-rels+area-rels+work-rels\&limit=25\&offset=150 |xsltproc -o recordings.html recordings.xsl -; google-chrome recordings.html

$ wget -O - https://musicbrainz.org/ws/2/release?artist=678d88b2-87b0-403b-b63d-5da7465aecc3\&type=live\&inc=release-groups+place-rels+event-rels+area-rels\&limit=25\&offset=25 |xsltproc -o releases.html releases.xsl -; google-chrome releases.html
